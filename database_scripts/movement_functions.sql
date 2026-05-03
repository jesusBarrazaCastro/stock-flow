	-- =============================================================
-- FUNCIÓN: public.write_movimientos
-- Registra movimientos de inventario (ENTRADA / SALIDA).
-- Parámetro AC (acción):
--   'register' → Valida stock, inserta movimiento y ajusta inventario
--
-- NOTA: p_almacen_id es opcional. Si es NULL, se auto-selecciona
--       el primer almacén activo de la empresa.
-- =============================================================
CREATE OR REPLACE FUNCTION public.write_movimientos(
    p_ac              TEXT,
    p_empresa_id      INT,
    p_producto_id     INT,
    p_almacen_id      INT            DEFAULT NULL,
    p_usuario_id      INT            DEFAULT NULL,
    p_tipo            TEXT           DEFAULT 'ENTRADA',
    p_cantidad        INT            DEFAULT NULL,
    p_precio          NUMERIC(12,2)  DEFAULT NULL,
    p_proveedor_id    INT            DEFAULT NULL,
    p_notas           TEXT           DEFAULT NULL,
    p_fecha           TIMESTAMP      DEFAULT NULL,
    p_fecha_caducidad DATE           DEFAULT NULL,
    p_lote_entrada_id INT            DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock_actual   INT;
    v_stock_nuevo    INT;
    v_movimiento_id  INT;
    v_fecha_uso      TIMESTAMP;
    v_almacen_id     INT;
BEGIN

    -- ── REGISTER ─────────────────────────────────────────────
    IF p_ac = 'register' THEN

        -- Validar cantidad
        IF p_cantidad IS NULL OR p_cantidad < 1 THEN
            RETURN jsonb_build_object('error', 'La cantidad debe ser mayor a cero');
        END IF;

        -- Validar tipo
        IF p_tipo NOT IN ('ENTRADA', 'SALIDA') THEN
            RETURN jsonb_build_object('error', 'Tipo de movimiento inválido. Use ENTRADA o SALIDA');
        END IF;

        -- Validar que el producto pertenezca a la empresa
        IF NOT EXISTS (
            SELECT 1 FROM productos
            WHERE id = p_producto_id
              AND empresa_id = p_empresa_id
              AND registro_estado = TRUE
        ) THEN
            RETURN jsonb_build_object('error', 'Producto no encontrado o sin permisos');
        END IF;

        -- Resolver almacén
        IF p_almacen_id IS NOT NULL THEN
            IF NOT EXISTS (
                SELECT 1 FROM almacenes
                WHERE id = p_almacen_id
                  AND empresa_id = p_empresa_id
                  AND registro_estado = TRUE
            ) THEN
                RETURN jsonb_build_object('error', 'Almacén no encontrado o sin permisos');
            END IF;
            v_almacen_id := p_almacen_id;
        ELSE
            -- Auto-seleccionar primer almacén activo de la empresa
            SELECT id INTO v_almacen_id
            FROM almacenes
            WHERE empresa_id     = p_empresa_id
              AND registro_estado = TRUE
              AND is_active        = TRUE
            ORDER BY id
            LIMIT 1;

            IF v_almacen_id IS NULL THEN
                -- Crear un almacén por defecto automáticamente
                INSERT INTO almacenes (empresa_id, nombre, is_active, registro_estado)
                VALUES (p_empresa_id, 'Almacén Principal', TRUE, TRUE)
                RETURNING id INTO v_almacen_id;
            END IF;
        END IF;

        -- Stock actual en el almacén resuelto
        SELECT COALESCE(cantidad_actual, 0)
        INTO v_stock_actual
        FROM inventario
        WHERE producto_id = p_producto_id
          AND almacen_id  = v_almacen_id
          AND registro_estado = TRUE;

        v_stock_actual := COALESCE(v_stock_actual, 0);

        -- Validar stock para SALIDA
        IF p_tipo = 'SALIDA' AND v_stock_actual < p_cantidad THEN
            RETURN jsonb_build_object(
                'error',
                'Stock insuficiente. Disponible: ' || v_stock_actual || ' unidades'
            );
        END IF;

        -- Validar lote específico para SALIDA
        IF p_tipo = 'SALIDA' AND p_lote_entrada_id IS NOT NULL THEN
            DECLARE
                v_lote_restante INT;
            BEGIN
                SELECT (mi.cantidad - COALESCE(SUM(s.cantidad), 0))
                INTO v_lote_restante
                FROM movimientos_inventario mi
                LEFT JOIN movimientos_inventario s
                       ON s.lote_entrada_id = mi.id
                      AND s.registro_estado  = TRUE
                WHERE mi.id              = p_lote_entrada_id
                  AND mi.tipo_movimiento  = 'ENTRADA'
                  AND mi.registro_estado  = TRUE
                  AND mi.producto_id      = p_producto_id
                GROUP BY mi.cantidad;

                IF v_lote_restante IS NULL THEN
                    RETURN jsonb_build_object('error', 'Lote no encontrado para este producto');
                END IF;

                IF v_lote_restante < p_cantidad THEN
                    RETURN jsonb_build_object(
                        'error',
                        'Stock insuficiente en el lote seleccionado. Disponible: ' || v_lote_restante || ' unidades'
                    );
                END IF;
            END;
        END IF;

        v_stock_nuevo := CASE
            WHEN p_tipo = 'ENTRADA' THEN v_stock_actual + p_cantidad
            ELSE v_stock_actual - p_cantidad
        END;

        v_fecha_uso := COALESCE(p_fecha, NOW());

        -- Insertar movimiento
        INSERT INTO movimientos_inventario (
            producto_id, almacen_id, usuario_id, proveedor_id,
            tipo_movimiento, cantidad, precio_unitario,
            fecha_movimiento, notas, metodo_registro, fecha_caducidad,
            lote_entrada_id, registro_usuario
        ) VALUES (
            p_producto_id, v_almacen_id, p_usuario_id, p_proveedor_id,
            p_tipo, p_cantidad, p_precio,
            v_fecha_uso, p_notas, 'MANUAL',
            CASE WHEN p_tipo = 'ENTRADA' THEN p_fecha_caducidad ELSE NULL END,
            CASE WHEN p_tipo = 'SALIDA' THEN p_lote_entrada_id ELSE NULL END,
            p_usuario_id
        )
        RETURNING id INTO v_movimiento_id;

        -- Ajustar inventario
        INSERT INTO inventario (
            producto_id, almacen_id, cantidad_actual, registro_usuario
        ) VALUES (
            p_producto_id, v_almacen_id, v_stock_nuevo, p_usuario_id
        )
        ON CONFLICT (producto_id, almacen_id) DO UPDATE
            SET cantidad_actual  = v_stock_nuevo,
                registro_usuario = p_usuario_id;

        RETURN jsonb_build_object(
            'ok',            true,
            'movimiento_id', v_movimiento_id,
            'stock_nuevo',   v_stock_nuevo
        );

    END IF;

    RETURN jsonb_build_object('error', 'Acción no reconocida: ' || COALESCE(p_ac, 'NULL'));
END;
$$;


-- =============================================================
-- FUNCIÓN: public.read_almacenes
-- Lee almacenes de la empresa en sesión.
-- =============================================================
CREATE OR REPLACE FUNCTION public.read_almacenes(
    p_ac          TEXT,
    p_empresa_id  INT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_items JSONB;
BEGIN

    IF p_ac = 'list' THEN

        SELECT jsonb_agg(row_to_json(a)::jsonb) INTO v_items
        FROM (
            SELECT id, nombre, direccion, capacidad_maxima, is_active
            FROM almacenes
            WHERE empresa_id     = p_empresa_id
              AND registro_estado = TRUE
              AND is_active       = TRUE
            ORDER BY nombre
        ) a;

        RETURN jsonb_build_object(
            'items', COALESCE(v_items, '[]'::jsonb)
        );

    END IF;

    RETURN jsonb_build_object('error', 'Acción no reconocida: ' || COALESCE(p_ac, 'NULL'));
END;
$$;
