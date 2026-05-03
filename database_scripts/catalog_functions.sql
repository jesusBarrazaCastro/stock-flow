-- =============================================================
-- FUNCIÓN: public.read_productos
-- Maneja todas las lecturas del catálogo de productos.
-- Parámetro AC (acción):
--   'list'       → Lista paginada con filtros y ordenamiento
--   'detail'     → Detalle de un producto con movimientos recientes
--   'categories' → Lista de categorías de la empresa
-- =============================================================
CREATE OR REPLACE FUNCTION public.read_productos(
    p_ac           TEXT,
    p_empresa_id   INT,
    p_producto_id  INT     DEFAULT NULL,
    p_search       TEXT    DEFAULT NULL,
    p_categoria_id INT     DEFAULT NULL,
    p_sort         TEXT    DEFAULT 'newest',
    p_page         INT     DEFAULT 1,
    p_limit        INT     DEFAULT 10
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset      INT;
    v_total       INT;
    v_items       JSONB;
    v_producto    RECORD;
    v_movimientos JSONB;
    v_inventario  RECORD;
    v_lotes       JSONB;
    v_dias_alerta INT;
BEGIN

    -- ── LIST ─────────────────────────────────────────────────────
    IF p_ac = 'list' THEN

        v_offset := (p_page - 1) * p_limit;

        SELECT COALESCE(e.dias_alerta_caducidad, 30) INTO v_dias_alerta
        FROM empresas e WHERE e.id = p_empresa_id;

        SELECT COUNT(*)
        INTO v_total
        FROM productos p
        WHERE p.empresa_id = p_empresa_id
          AND p.registro_estado = TRUE
          AND (p_search IS NULL OR p_search = ''
               OR p.nombre ILIKE '%' || p_search || '%'
               OR p.sku    ILIKE '%' || p_search || '%')
          AND (p_categoria_id IS NULL OR p.categoria_id = p_categoria_id);

        SELECT jsonb_agg(row_to_json(t)::jsonb) INTO v_items
        FROM (
            SELECT
                p.id,
                p.nombre,
                p.sku,
                p.descripcion,
                p.precio_unitario,
                p.imagen_url,
                p.unidad_medida,
                p.stock_minimo,
                p.stock_maximo,
                p.tiene_caducidad,
                to_char(p.registro_fecha, 'DD Mon YYYY') AS registro_fecha,
                c.id        AS categoria_id,
                c.nombre    AS categoria_nombre,
                c.color_hex AS categoria_color,
                prov.id     AS proveedor_id,
                prov.nombre AS proveedor_nombre,
                COALESCE(vsp.stock_total, 0)          AS stock_total,
                COALESCE(vsp.estado_stock, 'AGOTADO') AS estado_stock,
                (
                    SELECT MIN(mi.fecha_caducidad)
                    FROM movimientos_inventario mi
                    WHERE mi.producto_id       = p.id
                      AND mi.tipo_movimiento   = 'ENTRADA'
                      AND mi.registro_estado   = TRUE
                      AND mi.fecha_caducidad   IS NOT NULL
                      AND mi.fecha_caducidad   >= CURRENT_DATE
                ) AS proxima_caducidad,
                (
                    SELECT MIN(mi.fecha_caducidad) <= CURRENT_DATE + v_dias_alerta
                    FROM movimientos_inventario mi
                    WHERE mi.producto_id       = p.id
                      AND mi.tipo_movimiento   = 'ENTRADA'
                      AND mi.registro_estado   = TRUE
                      AND mi.fecha_caducidad   IS NOT NULL
                      AND mi.fecha_caducidad   >= CURRENT_DATE
                ) AS expira_pronto
            FROM productos p
            LEFT JOIN categorias c      ON c.id = p.categoria_id
            LEFT JOIN proveedores prov  ON prov.id = p.proveedor_id
            LEFT JOIN v_stock_productos vsp ON vsp.producto_id = p.id
            WHERE p.empresa_id = p_empresa_id
              AND p.registro_estado = TRUE
              AND (p_search IS NULL OR p_search = ''
                   OR p.nombre ILIKE '%' || p_search || '%'
                   OR p.sku    ILIKE '%' || p_search || '%')
              AND (p_categoria_id IS NULL OR p.categoria_id = p_categoria_id)
            ORDER BY
                CASE WHEN p_sort = 'newest'     THEN EXTRACT(EPOCH FROM p.registro_fecha) END DESC NULLS LAST,
                CASE WHEN p_sort = 'price_desc' THEN p.precio_unitario END DESC NULLS LAST,
                CASE WHEN p_sort = 'price_asc'  THEN p.precio_unitario END ASC NULLS LAST,
                p.registro_fecha DESC
            LIMIT p_limit OFFSET v_offset
        ) t;

        RETURN jsonb_build_object(
            'items', COALESCE(v_items, '[]'::jsonb),
            'total', v_total,
            'page',  p_page,
            'limit', p_limit,
            'pages', CEIL(v_total::FLOAT / NULLIF(p_limit, 0))
        );

    -- ── DETAIL ───────────────────────────────────────────────────
    ELSIF p_ac = 'detail' THEN

        SELECT COALESCE(e.dias_alerta_caducidad, 30) INTO v_dias_alerta
        FROM empresas e WHERE e.id = p_empresa_id;

        SELECT
            p.id, p.nombre, p.sku, p.descripcion,
            p.precio_unitario, p.imagen_url, p.unidad_medida,
            p.stock_minimo, p.stock_maximo, p.tiene_caducidad,
            to_char(p.registro_fecha, 'DD Mon YYYY') AS registro_fecha,
            c.id        AS categoria_id,
            c.nombre    AS categoria_nombre,
            c.color_hex AS categoria_color,
            prov.id     AS proveedor_id,
            prov.nombre AS proveedor_nombre,
            COALESCE(vsp.stock_total, 0)          AS stock_total,
            COALESCE(vsp.estado_stock, 'AGOTADO') AS estado_stock,
            (
                SELECT MIN(mi.fecha_caducidad)
                FROM movimientos_inventario mi
                WHERE mi.producto_id     = p.id
                  AND mi.tipo_movimiento = 'ENTRADA'
                  AND mi.registro_estado = TRUE
                  AND mi.fecha_caducidad IS NOT NULL
                  AND mi.fecha_caducidad >= CURRENT_DATE
            ) AS proxima_caducidad,
            (
                SELECT MIN(mi.fecha_caducidad) <= CURRENT_DATE + v_dias_alerta
                FROM movimientos_inventario mi
                WHERE mi.producto_id     = p.id
                  AND mi.tipo_movimiento = 'ENTRADA'
                  AND mi.registro_estado = TRUE
                  AND mi.fecha_caducidad IS NOT NULL
                  AND mi.fecha_caducidad >= CURRENT_DATE
            ) AS expira_pronto
        INTO v_producto
        FROM productos p
        LEFT JOIN categorias c      ON c.id = p.categoria_id
        LEFT JOIN proveedores prov  ON prov.id = p.proveedor_id
        LEFT JOIN v_stock_productos vsp ON vsp.producto_id = p.id
        WHERE p.id = p_producto_id
          AND p.empresa_id = p_empresa_id
          AND p.registro_estado = TRUE;

        IF NOT FOUND THEN
            RETURN jsonb_build_object('error', 'Producto no encontrado');
        END IF;

        SELECT jsonb_agg(row_to_json(m)::jsonb) INTO v_movimientos
        FROM (
            SELECT
                mi.id,
                mi.tipo_movimiento,
                mi.cantidad,
                mi.precio_unitario,
                to_char(mi.fecha_movimiento, 'DD Mon YYYY') AS fecha_movimiento,
                mi.notas,
                mi.metodo_registro,
                al.nombre               AS almacen_nombre,
                u.nombre_completo       AS usuario_nombre
            FROM movimientos_inventario mi
            LEFT JOIN almacenes al ON al.id = mi.almacen_id
            LEFT JOIN usuarios u   ON u.id  = mi.usuario_id
            WHERE mi.producto_id = p_producto_id
              AND mi.registro_estado = TRUE
            ORDER BY mi.fecha_movimiento DESC
            LIMIT 5
        ) m;

        -- Lotes con caducidad: muestra cantidad restante (ENTRADA - SALIDAs atribuidas)
        SELECT jsonb_agg(row_to_json(l)::jsonb ORDER BY l.fecha_caducidad ASC)
        INTO v_lotes
        FROM (
            SELECT
                mi.id                AS movimiento_id,
                (mi.cantidad - COALESCE(
                    (SELECT SUM(s.cantidad)
                       FROM movimientos_inventario s
                      WHERE s.lote_entrada_id = mi.id
                        AND s.registro_estado = TRUE),
                    0
                ))                   AS cantidad,
                mi.fecha_caducidad,
                (mi.fecha_caducidad - CURRENT_DATE)  AS dias_restantes,
                CASE
                    WHEN mi.fecha_caducidad < CURRENT_DATE              THEN 'VENCIDO'
                    WHEN mi.fecha_caducidad <= CURRENT_DATE + v_dias_alerta THEN 'PRONTO'
                    ELSE 'OK'
                END                  AS estado,
                al.nombre            AS almacen_nombre
            FROM movimientos_inventario mi
            LEFT JOIN almacenes al ON al.id = mi.almacen_id
            WHERE mi.producto_id     = p_producto_id
              AND mi.tipo_movimiento = 'ENTRADA'
              AND mi.registro_estado = TRUE
              AND mi.fecha_caducidad IS NOT NULL
              AND (mi.cantidad - COALESCE(
                    (SELECT SUM(s.cantidad)
                       FROM movimientos_inventario s
                      WHERE s.lote_entrada_id = mi.id
                        AND s.registro_estado = TRUE),
                    0
                  )) > 0
            ORDER BY mi.fecha_caducidad ASC
        ) l;

        SELECT i.almacen_id, i.ubicacion_fisica, al.nombre AS almacen_nombre
        INTO v_inventario
        FROM inventario i
        JOIN almacenes al ON al.id = i.almacen_id
        WHERE i.producto_id = p_producto_id
          AND i.registro_estado = TRUE
        ORDER BY i.cantidad_actual DESC
        LIMIT 1;

        RETURN jsonb_build_object(
            'id',                  v_producto.id,
            'nombre',              v_producto.nombre,
            'sku',                 v_producto.sku,
            'descripcion',         v_producto.descripcion,
            'precio_unitario',     v_producto.precio_unitario,
            'imagen_url',          v_producto.imagen_url,
            'unidad_medida',       v_producto.unidad_medida,
            'stock_minimo',        v_producto.stock_minimo,
            'stock_maximo',        v_producto.stock_maximo,
            'tiene_caducidad',     v_producto.tiene_caducidad,
            'proxima_caducidad',   v_producto.proxima_caducidad,
            'expira_pronto',       COALESCE(v_producto.expira_pronto, FALSE),
            'registro_fecha',      v_producto.registro_fecha,
            'categoria_id',        v_producto.categoria_id,
            'categoria_nombre',    v_producto.categoria_nombre,
            'categoria_color',     v_producto.categoria_color,
            'proveedor_id',        v_producto.proveedor_id,
            'proveedor_nombre',    v_producto.proveedor_nombre,
            'stock_total',         v_producto.stock_total,
            'estado_stock',        v_producto.estado_stock,
            'almacen_id',          v_inventario.almacen_id,
            'ubicacion_fisica',    v_inventario.ubicacion_fisica,
            'almacen_nombre',      v_inventario.almacen_nombre,
            'movimientos_recientes', COALESCE(v_movimientos, '[]'::jsonb),
            'lotes_caducidad',     COALESCE(v_lotes, '[]'::jsonb)
        );

    -- ── LOTES_DISPONIBLES ────────────────────────────────────────
    ELSIF p_ac = 'lotes_disponibles' THEN

        SELECT COALESCE(e.dias_alerta_caducidad, 30) INTO v_dias_alerta
        FROM empresas e WHERE e.id = p_empresa_id;

        SELECT jsonb_agg(row_to_json(l)::jsonb ORDER BY l.fecha_movimiento ASC)
        INTO v_items
        FROM (
            SELECT
                mi.id                AS movimiento_id,
                to_char(mi.fecha_movimiento, 'YYYY-MM-DD"T"HH24:MI:SS') AS fecha_movimiento,
                mi.fecha_caducidad,
                (mi.cantidad - COALESCE(SUM(s.cantidad), 0)) AS cantidad_restante,
                (mi.fecha_caducidad - CURRENT_DATE)          AS dias_restantes,
                CASE
                    WHEN mi.fecha_caducidad IS NULL                          THEN 'OK'
                    WHEN mi.fecha_caducidad < CURRENT_DATE                   THEN 'VENCIDO'
                    WHEN mi.fecha_caducidad <= CURRENT_DATE + v_dias_alerta  THEN 'PRONTO'
                    ELSE 'OK'
                END                  AS estado,
                al.nombre            AS almacen_nombre
            FROM movimientos_inventario mi
            LEFT JOIN movimientos_inventario s
                   ON s.lote_entrada_id = mi.id
                  AND s.registro_estado  = TRUE
            LEFT JOIN almacenes al ON al.id = mi.almacen_id
            JOIN productos p ON p.id = mi.producto_id
            WHERE mi.producto_id     = p_producto_id
              AND p.empresa_id       = p_empresa_id
              AND mi.tipo_movimiento = 'ENTRADA'
              AND mi.registro_estado = TRUE
              AND mi.fecha_caducidad IS NOT NULL
            GROUP BY mi.id, mi.fecha_movimiento, mi.fecha_caducidad, mi.cantidad, al.nombre
            HAVING (mi.cantidad - COALESCE(SUM(s.cantidad), 0)) > 0
            ORDER BY mi.fecha_movimiento ASC
        ) l;

        RETURN jsonb_build_object(
            'items', COALESCE(v_items, '[]'::jsonb)
        );

    -- ── CATEGORIES ───────────────────────────────────────────────
    ELSIF p_ac = 'categories' THEN

        SELECT jsonb_agg(row_to_json(c)::jsonb) INTO v_items
        FROM (
            SELECT id, nombre, color_hex
            FROM categorias
            WHERE registro_estado = TRUE
            ORDER BY nombre
        ) c;

        RETURN jsonb_build_object(
            'items', COALESCE(v_items, '[]'::jsonb)
        );

    END IF;

    RETURN jsonb_build_object('error', 'Acción no reconocida: ' || COALESCE(p_ac, 'NULL'));
END;
$$;


-- =============================================================
-- FUNCIÓN: public.write_productos
-- Maneja escrituras sobre productos e inventario.
-- Parámetro AC (acción):
--   'register' → Crea un nuevo producto en el catálogo
--   'update'   → Actualiza datos del producto y opcionalmente el inventario
-- =============================================================
CREATE OR REPLACE FUNCTION public.write_productos(
    p_ac               TEXT,
    p_empresa_id       INT,
    p_producto_id      INT             DEFAULT NULL,
    p_nombre           TEXT            DEFAULT NULL,
    p_sku              TEXT            DEFAULT NULL,
    p_descripcion      TEXT            DEFAULT NULL,
    p_precio_unitario  NUMERIC(12,2)   DEFAULT NULL,
    p_categoria_id     INT             DEFAULT NULL,
    p_proveedor_id     INT             DEFAULT NULL,
    p_unidad_medida    TEXT            DEFAULT NULL,
    p_stock_minimo     INT             DEFAULT NULL,
    p_stock_maximo     INT             DEFAULT NULL,
    p_imagen_url       TEXT            DEFAULT NULL,
    p_almacen_id       INT             DEFAULT NULL,
    p_ubicacion_fisica TEXT            DEFAULT NULL,
    p_cantidad_nueva   INT             DEFAULT NULL,
    p_usuario_id       INT             DEFAULT NULL,
    p_tiene_caducidad  BOOLEAN         DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_qty  INT;
    v_diff     INT;
    v_tipo     TEXT;
    v_nuevo_id INT;
BEGIN

    -- ── REGISTER ─────────────────────────────────────────────────
    IF p_ac = 'register' THEN

        IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
            RETURN jsonb_build_object('error', 'El nombre del producto es requerido');
        END IF;

        IF p_sku IS NULL OR TRIM(p_sku) = '' THEN
            RETURN jsonb_build_object('error', 'El SKU es requerido');
        END IF;

        IF EXISTS (
            SELECT 1 FROM productos
            WHERE sku = p_sku
              AND empresa_id = p_empresa_id
              AND registro_estado = TRUE
        ) THEN
            RETURN jsonb_build_object('error', 'Ya existe un producto con ese SKU en tu catálogo');
        END IF;

        INSERT INTO productos (
            empresa_id, nombre, sku, descripcion, precio_unitario,
            categoria_id, unidad_medida, stock_minimo, stock_maximo,
            imagen_url, tiene_caducidad, registro_usuario
        ) VALUES (
            p_empresa_id,
            TRIM(p_nombre),
            TRIM(p_sku),
            p_descripcion,
            COALESCE(p_precio_unitario, 0),
            p_categoria_id,
            COALESCE(NULLIF(p_unidad_medida, ''), 'unidad'),
            COALESCE(p_stock_minimo, 0),
            p_stock_maximo,
            p_imagen_url,
            COALESCE(p_tiene_caducidad, FALSE),
            p_usuario_id
        )
        RETURNING id INTO v_nuevo_id;

        RETURN jsonb_build_object(
            'ok',     true,
            'id',     v_nuevo_id,
            'nombre', TRIM(p_nombre),
            'sku',    TRIM(p_sku)
        );

    -- ── UPDATE ───────────────────────────────────────────────────
    ELSIF p_ac = 'update' THEN

        IF NOT EXISTS (
            SELECT 1 FROM productos
            WHERE id = p_producto_id
              AND empresa_id = p_empresa_id
              AND registro_estado = TRUE
        ) THEN
            RETURN jsonb_build_object('error', 'Producto no encontrado o sin permisos');
        END IF;

        UPDATE productos SET
            nombre          = COALESCE(NULLIF(p_nombre, ''),       nombre),
            sku             = COALESCE(NULLIF(p_sku, ''),          sku),
            descripcion     = COALESCE(p_descripcion,              descripcion),
            precio_unitario = COALESCE(p_precio_unitario,          precio_unitario),
            categoria_id    = COALESCE(p_categoria_id,             categoria_id),
            proveedor_id    = COALESCE(p_proveedor_id,             proveedor_id),
            unidad_medida   = COALESCE(NULLIF(p_unidad_medida,''), unidad_medida),
            stock_minimo    = COALESCE(p_stock_minimo,             stock_minimo),
            stock_maximo    = COALESCE(p_stock_maximo,             stock_maximo),
            imagen_url      = COALESCE(p_imagen_url,               imagen_url),
            tiene_caducidad = COALESCE(p_tiene_caducidad,          tiene_caducidad)
        WHERE id = p_producto_id;

        IF p_almacen_id IS NOT NULL AND p_ubicacion_fisica IS NOT NULL THEN
            UPDATE inventario SET
                ubicacion_fisica = p_ubicacion_fisica
            WHERE producto_id  = p_producto_id
              AND almacen_id   = p_almacen_id
              AND registro_estado = TRUE;
        END IF;

        IF p_cantidad_nueva IS NOT NULL AND p_almacen_id IS NOT NULL AND p_usuario_id IS NOT NULL THEN

            SELECT cantidad_actual INTO v_old_qty
            FROM inventario
            WHERE producto_id = p_producto_id
              AND almacen_id  = p_almacen_id
              AND registro_estado = TRUE;

            v_diff := p_cantidad_nueva - COALESCE(v_old_qty, 0);

            IF v_diff <> 0 THEN
                v_tipo := CASE WHEN v_diff > 0 THEN 'ENTRADA' ELSE 'SALIDA' END;

                INSERT INTO inventario (producto_id, almacen_id, cantidad_actual, ubicacion_fisica)
                VALUES (p_producto_id, p_almacen_id, p_cantidad_nueva, p_ubicacion_fisica)
                ON CONFLICT (producto_id, almacen_id)
                DO UPDATE SET
                    cantidad_actual  = p_cantidad_nueva,
                    ubicacion_fisica = COALESCE(p_ubicacion_fisica, inventario.ubicacion_fisica);

                INSERT INTO movimientos_inventario
                    (producto_id, almacen_id, usuario_id, tipo_movimiento, cantidad,
                     precio_unitario, notas, metodo_registro)
                VALUES
                    (p_producto_id, p_almacen_id, p_usuario_id, v_tipo, ABS(v_diff),
                     p_precio_unitario, 'Actualización desde Catálogo', 'MANUAL');
            END IF;
        END IF;

        RETURN jsonb_build_object('ok', true, 'id', p_producto_id);

    END IF;

    RETURN jsonb_build_object('error', 'Acción no reconocida: ' || COALESCE(p_ac, 'NULL'));
END;
$$;


-- =============================================================
-- FUNCIÓN: public.read_caducidades
-- Lista lotes próximos a vencer de toda la empresa.
-- Parámetro AC (acción):
--   'list' → Todos los lotes con fecha_caducidad registrada, ordenados por fecha
-- =============================================================
CREATE OR REPLACE FUNCTION public.read_caducidades(
    p_ac         TEXT,
    p_empresa_id INT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_items       JSONB;
    v_dias_alerta INT;
BEGIN

    IF p_ac = 'list' THEN

        SELECT COALESCE(e.dias_alerta_caducidad, 30) INTO v_dias_alerta
        FROM empresas e WHERE e.id = p_empresa_id;

        SELECT jsonb_agg(row_to_json(t)::jsonb ORDER BY t.fecha_caducidad ASC)
        INTO v_items
        FROM (
            SELECT
                mi.id                                           AS movimiento_id,
                mi.producto_id,
                p.nombre                                        AS producto_nombre,
                p.unidad_medida,
                mi.cantidad,
                to_char(mi.fecha_caducidad, 'YYYY-MM-DD')       AS fecha_caducidad,
                (mi.fecha_caducidad - CURRENT_DATE)             AS dias_restantes,
                CASE
                    WHEN mi.fecha_caducidad < CURRENT_DATE               THEN 'VENCIDO'
                    WHEN mi.fecha_caducidad <= CURRENT_DATE + v_dias_alerta THEN 'PRONTO'
                    ELSE 'OK'
                END                                             AS estado
            FROM movimientos_inventario mi
            JOIN productos p ON p.id = mi.producto_id
            WHERE p.empresa_id       = p_empresa_id
              AND p.registro_estado  = TRUE
              AND mi.tipo_movimiento = 'ENTRADA'
              AND mi.registro_estado = TRUE
              AND mi.fecha_caducidad IS NOT NULL
              AND mi.fecha_caducidad >= CURRENT_DATE - INTERVAL '1 day'
            ORDER BY mi.fecha_caducidad ASC
        ) t;

        RETURN jsonb_build_object(
            'items', COALESCE(v_items, '[]'::jsonb)
        );

    END IF;

    RETURN jsonb_build_object('error', 'Acción no reconocida: ' || COALESCE(p_ac, 'NULL'));
END;
$$;
