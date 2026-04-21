-- =============================================================
-- MIGRACIONES: Columnas adicionales en proveedores
-- Ejecutar antes de las funciones si la tabla ya existe.
-- =============================================================
ALTER TABLE proveedores ADD COLUMN IF NOT EXISTS categoria       VARCHAR(150);
ALTER TABLE proveedores ADD COLUMN IF NOT EXISTS dias_entrega    INTEGER DEFAULT 5;
ALTER TABLE proveedores ADD COLUMN IF NOT EXISTS logo_url        TEXT;
ALTER TABLE proveedores ADD COLUMN IF NOT EXISTS calificacion    NUMERIC(3,1) DEFAULT 0;
ALTER TABLE proveedores ADD COLUMN IF NOT EXISTS certificado_desde INTEGER;  -- Año de certificación


-- =============================================================
-- FUNCIÓN: public.read_proveedores
-- Maneja todas las lecturas del catálogo de proveedores.
-- Parámetro AC (acción):
--   'list'   → Lista paginada con búsqueda y stats de red
--   'detail' → Detalle con productos, KPIs e historial de pedidos
-- =============================================================
CREATE OR REPLACE FUNCTION public.read_proveedores(
    p_ac           TEXT,
    p_empresa_id   INT,
    p_proveedor_id INT     DEFAULT NULL,
    p_search       TEXT    DEFAULT NULL,
    p_categoria    TEXT    DEFAULT NULL,
    p_page         INT     DEFAULT 1,
    p_limit        INT     DEFAULT 20
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset        INT;
    v_total         INT;
    v_items         JSONB;
    v_proveedor     RECORD;
    v_productos     JSONB;
    v_historial     JSONB;
    v_aliados_total INT;
    v_nuevos        INT;
    v_en_revision   INT;
    v_pedidos_total INT;
    v_cumplimiento  NUMERIC;
    v_tiempo_entrega NUMERIC;
BEGIN

    -- ── LIST ─────────────────────────────────────────────────────
    IF p_ac = 'list' THEN

        v_offset := (p_page - 1) * p_limit;

        -- Stats de red
        SELECT COUNT(*) INTO v_aliados_total
        FROM proveedores
        WHERE empresa_id = p_empresa_id AND registro_estado = TRUE;

        SELECT COUNT(*) INTO v_nuevos
        FROM proveedores
        WHERE empresa_id = p_empresa_id
          AND registro_estado = TRUE
          AND registro_fecha >= NOW() - INTERVAL '7 days';

        -- En revisión: proveedores sin email de contacto (pendientes de completar)
        SELECT COUNT(*) INTO v_en_revision
        FROM proveedores
        WHERE empresa_id = p_empresa_id
          AND registro_estado = TRUE
          AND (contacto_email IS NULL OR TRIM(contacto_email) = '');

        SELECT COUNT(*) INTO v_total
        FROM proveedores p
        WHERE p.empresa_id = p_empresa_id
          AND p.registro_estado = TRUE
          AND (p_search IS NULL OR p_search = ''
               OR p.nombre ILIKE '%' || p_search || '%'
               OR p.categoria ILIKE '%' || p_search || '%')
          AND (p_categoria IS NULL OR p_categoria = ''
               OR p.categoria ILIKE p_categoria);

        SELECT jsonb_agg(row_to_json(t)::jsonb) INTO v_items
        FROM (
            SELECT
                p.id,
                p.nombre,
                p.categoria,
                p.contacto_nombre,
                p.contacto_email,
                p.contacto_telefono,
                p.direccion,
                p.dias_entrega,
                p.logo_url,
                p.calificacion,
                p.certificado_desde,
                p.notas,
                to_char(p.registro_fecha, 'DD Mon YYYY') AS registro_fecha,
                -- Estado: ACTIVO si tiene email, EN_REVISION si no
                CASE
                    WHEN p.contacto_email IS NOT NULL AND TRIM(p.contacto_email) != ''
                    THEN 'ACTIVO'
                    ELSE 'EN_REVISION'
                END AS estado,
                -- Total de productos asignados a este proveedor
                (SELECT COUNT(*) FROM productos pr
                 WHERE pr.proveedor_id = p.id AND pr.registro_estado = TRUE
                ) AS total_productos
            FROM proveedores p
            WHERE p.empresa_id = p_empresa_id
              AND p.registro_estado = TRUE
              AND (p_search IS NULL OR p_search = ''
                   OR p.nombre ILIKE '%' || p_search || '%'
                   OR p.categoria ILIKE '%' || p_search || '%')
              AND (p_categoria IS NULL OR p_categoria = ''
                   OR p.categoria ILIKE p_categoria)
            ORDER BY p.registro_fecha DESC
            LIMIT p_limit OFFSET v_offset
        ) t;

        RETURN jsonb_build_object(
            'items',         COALESCE(v_items, '[]'::jsonb),
            'total',         v_total,
            'page',          p_page,
            'limit',         p_limit,
            'pages',         CEIL(v_total::FLOAT / NULLIF(p_limit, 0)),
            'aliados_total', v_aliados_total,
            'nuevos',        v_nuevos,
            'en_revision',   v_en_revision
        );

    -- ── DETAIL ───────────────────────────────────────────────────
    ELSIF p_ac = 'detail' THEN

        SELECT
            p.id, p.nombre, p.categoria, p.contacto_nombre,
            p.contacto_email, p.contacto_telefono, p.direccion,
            p.dias_entrega, p.logo_url, p.calificacion,
            p.certificado_desde, p.notas,
            to_char(p.registro_fecha, 'DD Mon YYYY') AS registro_fecha,
            CASE
                WHEN p.contacto_email IS NOT NULL AND TRIM(p.contacto_email) != ''
                THEN 'ACTIVO'
                ELSE 'EN_REVISION'
            END AS estado
        INTO v_proveedor
        FROM proveedores p
        WHERE p.id = p_proveedor_id
          AND p.empresa_id = p_empresa_id
          AND p.registro_estado = TRUE;

        IF NOT FOUND THEN
            RETURN jsonb_build_object('error', 'Proveedor no encontrado');
        END IF;

        -- Productos suministrados por este proveedor
        SELECT jsonb_agg(row_to_json(pr)::jsonb) INTO v_productos
        FROM (
            SELECT
                p.id,
                p.nombre,
                p.sku,
                p.imagen_url,
                c.nombre AS categoria_nombre,
                c.color_hex AS categoria_color,
                COALESCE(vsp.stock_total, 0) AS stock_total
            FROM productos p
            LEFT JOIN categorias c ON c.id = p.categoria_id
            LEFT JOIN v_stock_productos vsp ON vsp.producto_id = p.id
            WHERE p.proveedor_id = p_proveedor_id
              AND p.empresa_id = p_empresa_id
              AND p.registro_estado = TRUE
            ORDER BY p.nombre
            LIMIT 8
        ) pr;

        -- KPIs: pedidos totales (movimientos ENTRADA relacionados a sus productos)
        SELECT
            COUNT(*)             AS pedidos_total,
            -- Cumplimiento: % de movimientos a tiempo (si dias_entrega > 0 usamos heurística)
            ROUND(
                CASE
                    WHEN COUNT(*) > 0 THEN
                        (COUNT(*) FILTER (WHERE mi.cantidad > 0)::NUMERIC / COUNT(*)) * 100
                    ELSE 0
                END, 1
            ) AS cumplimiento,
            -- Tiempo entrega promedio en días (usando dias_entrega del proveedor como referencia)
            COALESCE(v_proveedor.dias_entrega, 5)::NUMERIC AS tiempo_entrega
        INTO v_pedidos_total, v_cumplimiento, v_tiempo_entrega
        FROM movimientos_inventario mi
        JOIN productos p ON p.id = mi.producto_id
        WHERE p.proveedor_id = p_proveedor_id
          AND p.empresa_id = p_empresa_id
          AND mi.tipo_movimiento = 'ENTRADA'
          AND mi.registro_estado = TRUE;

        -- Historial de pedidos (últimos movimientos de ENTRADA)
        SELECT jsonb_agg(row_to_json(h)::jsonb) INTO v_historial
        FROM (
            SELECT
                mi.id,
                'PO-' || LPAD(mi.id::TEXT, 5, '0') AS numero_pedido,
                to_char(mi.fecha_movimiento, 'DD de FMMonth, YYYY') AS fecha,
                mi.cantidad,
                mi.precio_unitario,
                COALESCE(mi.cantidad * mi.precio_unitario, 0) AS monto_total,
                p.nombre AS producto_nombre,
                -- Estado basado en antigüedad del movimiento
                CASE
                    WHEN mi.fecha_movimiento >= NOW() - INTERVAL '7 days' THEN 'EN_TRANSITO'
                    ELSE 'COMPLETADO'
                END AS estado_pedido
            FROM movimientos_inventario mi
            JOIN productos p ON p.id = mi.producto_id
            WHERE p.proveedor_id = p_proveedor_id
              AND p.empresa_id = p_empresa_id
              AND mi.tipo_movimiento = 'ENTRADA'
              AND mi.registro_estado = TRUE
            ORDER BY mi.fecha_movimiento DESC
            LIMIT 10
        ) h;

        RETURN jsonb_build_object(
            'id',                 v_proveedor.id,
            'nombre',             v_proveedor.nombre,
            'categoria',          v_proveedor.categoria,
            'contacto_nombre',    v_proveedor.contacto_nombre,
            'contacto_email',     v_proveedor.contacto_email,
            'contacto_telefono',  v_proveedor.contacto_telefono,
            'direccion',          v_proveedor.direccion,
            'dias_entrega',       v_proveedor.dias_entrega,
            'logo_url',           v_proveedor.logo_url,
            'calificacion',       v_proveedor.calificacion,
            'certificado_desde',  v_proveedor.certificado_desde,
            'notas',              v_proveedor.notas,
            'registro_fecha',     v_proveedor.registro_fecha,
            'estado',             v_proveedor.estado,
            'productos_suministrados', COALESCE(v_productos, '[]'::jsonb),
            'pedidos_total',      COALESCE(v_pedidos_total, 0),
            'cumplimiento',       COALESCE(v_cumplimiento, 0),
            'tiempo_entrega',     COALESCE(v_tiempo_entrega, 0),
            'historial_pedidos',  COALESCE(v_historial, '[]'::jsonb)
        );

    END IF;

    RETURN jsonb_build_object('error', 'Acción no reconocida: ' || COALESCE(p_ac, 'NULL'));
END;
$$;


-- =============================================================
-- FUNCIÓN: public.write_proveedores
-- Maneja escrituras sobre proveedores.
-- Parámetro AC (acción):
--   'register' → Crea un nuevo proveedor
--   'update'   → Actualiza datos del proveedor
-- =============================================================
CREATE OR REPLACE FUNCTION public.write_proveedores(
    p_ac                TEXT,
    p_empresa_id        INT,
    p_proveedor_id      INT             DEFAULT NULL,
    p_nombre            TEXT            DEFAULT NULL,
    p_categoria         TEXT            DEFAULT NULL,
    p_contacto_nombre   TEXT            DEFAULT NULL,
    p_contacto_email    TEXT            DEFAULT NULL,
    p_contacto_telefono TEXT            DEFAULT NULL,
    p_direccion         TEXT            DEFAULT NULL,
    p_dias_entrega      INT             DEFAULT NULL,
    p_logo_url          TEXT            DEFAULT NULL,
    p_calificacion      NUMERIC(3,1)    DEFAULT NULL,
    p_certificado_desde INT             DEFAULT NULL,
    p_notas             TEXT            DEFAULT NULL,
    p_usuario_id        INT             DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_nuevo_id INT;
BEGIN

    -- ── REGISTER ─────────────────────────────────────────────────
    IF p_ac = 'register' THEN

        IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
            RETURN jsonb_build_object('error', 'El nombre del proveedor es requerido');
        END IF;

        IF EXISTS (
            SELECT 1 FROM proveedores
            WHERE LOWER(TRIM(nombre)) = LOWER(TRIM(p_nombre))
              AND empresa_id = p_empresa_id
              AND registro_estado = TRUE
        ) THEN
            RETURN jsonb_build_object('error', 'Ya existe un proveedor con ese nombre');
        END IF;

        INSERT INTO proveedores (
            empresa_id, nombre, categoria, contacto_nombre,
            contacto_email, contacto_telefono, direccion,
            dias_entrega, logo_url, calificacion, certificado_desde,
            notas, registro_usuario
        ) VALUES (
            p_empresa_id,
            TRIM(p_nombre),
            NULLIF(TRIM(COALESCE(p_categoria, '')), ''),
            NULLIF(TRIM(COALESCE(p_contacto_nombre, '')), ''),
            NULLIF(TRIM(COALESCE(p_contacto_email, '')), ''),
            NULLIF(TRIM(COALESCE(p_contacto_telefono, '')), ''),
            NULLIF(TRIM(COALESCE(p_direccion, '')), ''),
            COALESCE(p_dias_entrega, 5),
            NULLIF(TRIM(COALESCE(p_logo_url, '')), ''),
            COALESCE(p_calificacion, 0),
            p_certificado_desde,
            NULLIF(TRIM(COALESCE(p_notas, '')), ''),
            p_usuario_id
        )
        RETURNING id INTO v_nuevo_id;

        RETURN jsonb_build_object(
            'ok',     true,
            'id',     v_nuevo_id,
            'nombre', TRIM(p_nombre)
        );

    -- ── UPDATE ───────────────────────────────────────────────────
    ELSIF p_ac = 'update' THEN

        IF NOT EXISTS (
            SELECT 1 FROM proveedores
            WHERE id = p_proveedor_id
              AND empresa_id = p_empresa_id
              AND registro_estado = TRUE
        ) THEN
            RETURN jsonb_build_object('error', 'Proveedor no encontrado o sin permisos');
        END IF;

        UPDATE proveedores SET
            nombre              = COALESCE(NULLIF(TRIM(p_nombre), ''),            nombre),
            categoria           = COALESCE(NULLIF(TRIM(p_categoria), ''),         categoria),
            contacto_nombre     = COALESCE(NULLIF(TRIM(p_contacto_nombre), ''),   contacto_nombre),
            contacto_email      = COALESCE(NULLIF(TRIM(p_contacto_email), ''),    contacto_email),
            contacto_telefono   = COALESCE(NULLIF(TRIM(p_contacto_telefono), ''), contacto_telefono),
            direccion           = COALESCE(NULLIF(TRIM(p_direccion), ''),          direccion),
            dias_entrega        = COALESCE(p_dias_entrega,                         dias_entrega),
            logo_url            = COALESCE(NULLIF(TRIM(p_logo_url), ''),           logo_url),
            calificacion        = COALESCE(p_calificacion,                         calificacion),
            certificado_desde   = COALESCE(p_certificado_desde,                    certificado_desde),
            notas               = COALESCE(NULLIF(TRIM(p_notas), ''),              notas)
        WHERE id = p_proveedor_id
          AND empresa_id = p_empresa_id;

        RETURN jsonb_build_object('ok', true, 'id', p_proveedor_id);

    END IF;

    RETURN jsonb_build_object('error', 'Acción no reconocida: ' || COALESCE(p_ac, 'NULL'));
END;
$$;
