-- =============================================================================
-- FUNCIÓN: public.read_dashboard
-- Maneja todas las lecturas del dashboard principal.
-- Acciones (p_ac):
--   'kpis'      → KPIs de inventario: total unidades, productos, almacenes, capacidad, proximos_caducar, alertas_stock
--   'actividad' → Últimos p_limit movimientos de la empresa
--   'insights'  → Producto top + variación semanal + totales por día (7 días)
-- =============================================================================
CREATE OR REPLACE FUNCTION public.read_dashboard(
    p_ac         TEXT,
    p_empresa_id INT,
    p_limit      INT DEFAULT 5
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result              JSONB;
    v_items               JSONB;
    v_producto_id         INT;
    v_producto_nombre     TEXT;
    v_semana_actual       BIGINT;
    v_semana_anterior     BIGINT;
    v_pct_cambio          NUMERIC(10, 2);
    v_dias                JSONB;
    v_dias_alerta         INT;
BEGIN

    -- ── KPIS ──────────────────────────────────────────────────────────────
    IF p_ac = 'kpis' THEN

        SELECT COALESCE(e.dias_alerta_caducidad, 30) INTO v_dias_alerta
        FROM empresas e WHERE e.id = p_empresa_id;

        SELECT jsonb_build_object(
            'inventario_total_unidades', (
                SELECT COALESCE(SUM(i.cantidad_actual), 0)
                FROM inventario i
                JOIN productos p ON p.id = i.producto_id
                WHERE p.empresa_id     = p_empresa_id
                  AND p.registro_estado = TRUE
                  AND i.registro_estado = TRUE
            ),
            'total_productos', (
                SELECT COUNT(*)
                FROM productos
                WHERE empresa_id      = p_empresa_id
                  AND registro_estado = TRUE
            ),
            'total_almacenes', (
                SELECT COUNT(*)
                FROM almacenes
                WHERE empresa_id      = p_empresa_id
                  AND registro_estado = TRUE
                  AND is_active        = TRUE
            ),
            'capacidad_total', (
                SELECT COALESCE(SUM(capacidad_maxima), 0)
                FROM almacenes
                WHERE empresa_id      = p_empresa_id
                  AND registro_estado = TRUE
                  AND is_active        = TRUE
            ),
            'proximos_caducar', (
                SELECT COUNT(DISTINCT mi.producto_id)
                FROM movimientos_inventario mi
                JOIN productos p ON p.id = mi.producto_id
                WHERE p.empresa_id       = p_empresa_id
                  AND p.registro_estado  = TRUE
                  AND mi.tipo_movimiento = 'ENTRADA'
                  AND mi.registro_estado = TRUE
                  AND mi.fecha_caducidad IS NOT NULL
                  AND mi.fecha_caducidad BETWEEN CURRENT_DATE AND CURRENT_DATE + v_dias_alerta
            ),
            'alertas_stock', (
                SELECT COUNT(*)
                FROM v_stock_productos vsp
                JOIN productos p ON p.id = vsp.producto_id
                WHERE p.empresa_id      = p_empresa_id
                  AND p.registro_estado = TRUE
                  AND vsp.estado_stock IN ('AGOTADO', 'STOCK_BAJO')
            )
        ) INTO v_result;

        RETURN COALESCE(v_result, jsonb_build_object(
            'inventario_total_unidades', 0,
            'total_productos',           0,
            'total_almacenes',           0,
            'capacidad_total',           0,
            'proximos_caducar',          0,
            'alertas_stock',             0
        ));

    -- ── ACTIVIDAD ─────────────────────────────────────────────────────────
    ELSIF p_ac = 'actividad' THEN

        SELECT jsonb_agg(row_to_json(t)::jsonb)
        INTO v_items
        FROM (
            SELECT
                mi.id,
                mi.tipo_movimiento,
                mi.cantidad,
                to_char(
                    mi.fecha_movimiento AT TIME ZONE 'UTC',
                    'YYYY-MM-DD"T"HH24:MI:SS"Z"'
                )               AS fecha_movimiento,
                p.nombre        AS producto_nombre,
                al.nombre       AS almacen_nombre
            FROM movimientos_inventario mi
            JOIN productos p
                ON p.id           = mi.producto_id
               AND p.empresa_id   = p_empresa_id
               AND p.registro_estado = TRUE
            LEFT JOIN almacenes al
                ON al.id = mi.almacen_id
            WHERE mi.registro_estado = TRUE
            ORDER BY mi.fecha_movimiento DESC
            LIMIT p_limit
        ) t;

        RETURN jsonb_build_object(
            'items', COALESCE(v_items, '[]'::jsonb)
        );

    -- ── INSIGHTS ──────────────────────────────────────────────────────────
    ELSIF p_ac = 'insights' THEN

        -- Verificar si hay datos en los últimos 30 días
        IF NOT EXISTS (
            SELECT 1
            FROM movimientos_inventario mi
            JOIN productos p
                ON p.id           = mi.producto_id
               AND p.empresa_id   = p_empresa_id
               AND p.registro_estado = TRUE
            WHERE mi.registro_estado = TRUE
              AND mi.fecha_movimiento >= NOW() - INTERVAL '30 days'
        ) THEN
            RETURN jsonb_build_object('sin_datos', TRUE);
        END IF;

        -- Producto con más movimientos en últimos 30 días
        SELECT p.id, p.nombre
        INTO v_producto_id, v_producto_nombre
        FROM movimientos_inventario mi
        JOIN productos p
            ON p.id           = mi.producto_id
           AND p.empresa_id   = p_empresa_id
           AND p.registro_estado = TRUE
        WHERE mi.registro_estado = TRUE
          AND mi.fecha_movimiento >= NOW() - INTERVAL '30 days'
        GROUP BY p.id, p.nombre
        ORDER BY COUNT(*) DESC
        LIMIT 1;

        -- Total semana actual (lunes de esta semana → ahora)
        SELECT COALESCE(SUM(mi.cantidad), 0)
        INTO v_semana_actual
        FROM movimientos_inventario mi
        JOIN productos p
            ON p.id           = mi.producto_id
           AND p.empresa_id   = p_empresa_id
           AND p.registro_estado = TRUE
        WHERE mi.registro_estado = TRUE
          AND mi.fecha_movimiento >= date_trunc('week', NOW())
          AND mi.fecha_movimiento <  date_trunc('week', NOW()) + INTERVAL '7 days';

        -- Total semana anterior
        SELECT COALESCE(SUM(mi.cantidad), 0)
        INTO v_semana_anterior
        FROM movimientos_inventario mi
        JOIN productos p
            ON p.id           = mi.producto_id
           AND p.empresa_id   = p_empresa_id
           AND p.registro_estado = TRUE
        WHERE mi.registro_estado = TRUE
          AND mi.fecha_movimiento >= date_trunc('week', NOW()) - INTERVAL '7 days'
          AND mi.fecha_movimiento <  date_trunc('week', NOW());

        -- Calcular variación %
        IF v_semana_anterior = 0 THEN
            v_pct_cambio := CASE WHEN v_semana_actual > 0 THEN 100.0 ELSE 0.0 END;
        ELSE
            v_pct_cambio := ROUND(
                ((v_semana_actual::NUMERIC - v_semana_anterior) / v_semana_anterior) * 100.0,
                1
            );
        END IF;

        -- Totales por día últimos 7 días (todos los productos de la empresa)
        SELECT jsonb_agg(
            jsonb_build_object(
                'fecha', to_char(dias.dia, 'YYYY-MM-DD'),
                'total', COALESCE(mv.total, 0)
            )
            ORDER BY dias.dia
        )
        INTO v_dias
        FROM (
            SELECT generate_series(
                (NOW() - INTERVAL '6 days')::date,
                NOW()::date,
                '1 day'::interval
            )::date AS dia
        ) dias
        LEFT JOIN (
            SELECT
                mi.fecha_movimiento::date AS dia,
                SUM(mi.cantidad)          AS total
            FROM movimientos_inventario mi
            JOIN productos p
                ON p.id           = mi.producto_id
               AND p.empresa_id   = p_empresa_id
               AND p.registro_estado = TRUE
            WHERE mi.registro_estado = TRUE
              AND mi.fecha_movimiento >= (NOW() - INTERVAL '6 days')::date
            GROUP BY mi.fecha_movimiento::date
        ) mv ON mv.dia = dias.dia;

        RETURN jsonb_build_object(
            'sin_datos',       FALSE,
            'producto_nombre', v_producto_nombre,
            'pct_cambio',      v_pct_cambio,
            'dias',            COALESCE(v_dias, '[]'::jsonb)
        );

    END IF;

    RETURN jsonb_build_object('error', 'Acción no reconocida: ' || COALESCE(p_ac, 'NULL'));
END;
$$;
