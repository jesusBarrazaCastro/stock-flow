-- =============================================================
-- MIGRACIÓN: Seguimiento de lotes por salida (FIFO)
-- Agrega lote_entrada_id a movimientos_inventario y la SP
-- write_lotes para edición de fechas de caducidad.
-- =============================================================

-- 1. Nueva columna: lote_entrada_id
ALTER TABLE movimientos_inventario
    ADD COLUMN IF NOT EXISTS lote_entrada_id INTEGER
    REFERENCES movimientos_inventario(id) DEFAULT NULL;

CREATE INDEX IF NOT EXISTS idx_movimientos_lote_entrada_id
    ON movimientos_inventario(lote_entrada_id);


-- =============================================================
-- FUNCIÓN: public.write_lotes
-- Maneja escrituras sobre lotes (fechas de caducidad).
-- Parámetro AC (acción):
--   'update_caducidad' → Actualiza la fecha de caducidad de un lote (ENTRADA)
-- =============================================================
CREATE OR REPLACE FUNCTION public.write_lotes(
    p_ac             TEXT,
    p_empresa_id     INT,
    p_movimiento_id  INT  DEFAULT NULL,
    p_nueva_fecha    DATE DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_found BOOLEAN;
BEGIN

    -- ── UPDATE_CADUCIDAD ──────────────────────────────────────
    IF p_ac = 'update_caducidad' THEN

        IF p_movimiento_id IS NULL OR p_nueva_fecha IS NULL THEN
            RETURN jsonb_build_object('error', 'Se requiere movimiento_id y nueva_fecha');
        END IF;

        SELECT EXISTS (
            SELECT 1
            FROM movimientos_inventario mi
            JOIN productos p ON p.id = mi.producto_id
            WHERE mi.id              = p_movimiento_id
              AND p.empresa_id       = p_empresa_id
              AND mi.tipo_movimiento = 'ENTRADA'
              AND mi.registro_estado = TRUE
        ) INTO v_found;

        IF NOT v_found THEN
            RETURN jsonb_build_object('error', 'Lote no encontrado o sin permisos');
        END IF;

        UPDATE movimientos_inventario
           SET fecha_caducidad = p_nueva_fecha
         WHERE id = p_movimiento_id;

        RETURN jsonb_build_object('ok', true, 'movimiento_id', p_movimiento_id);

    END IF;

    RETURN jsonb_build_object('error', 'Acción no reconocida: ' || COALESCE(p_ac, 'NULL'));
END;
$$;
