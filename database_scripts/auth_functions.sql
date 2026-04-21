-- =============================================================
-- FUNCIÓN: public.write_usuarios
-- Maneja todas las escrituras sobre la tabla usuarios.
-- Parámetro AC (acción):
--   'register' → Crea un nuevo usuario
-- =============================================================
CREATE OR REPLACE FUNCTION public.write_usuarios(
    p_ac            TEXT,
    p_nombre        TEXT    DEFAULT NULL,
    p_negocio       TEXT    DEFAULT NULL,
    p_email         TEXT    DEFAULT NULL,
    p_password_hash TEXT    DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_user_id    INT;
    v_empresa_id INT;
    v_rol_id     INT;
BEGIN

    -- ── REGISTER ─────────────────────────────────────────────
    IF p_ac = 'register' THEN

        IF EXISTS (SELECT 1 FROM usuarios WHERE email = p_email) THEN
            RETURN jsonb_build_object('error', 'El email ya está registrado');
        END IF;

        -- Crear la empresa con el nombre del negocio
        INSERT INTO empresas (razon_social)
        VALUES (COALESCE(NULLIF(p_negocio, ''), 'Mi Empresa'))
        RETURNING id INTO v_empresa_id;

        -- Obtener el primer rol disponible (Admin por defecto)
        SELECT id INTO v_rol_id FROM roles ORDER BY id LIMIT 1;
        IF v_rol_id IS NULL THEN
            v_rol_id := 1;
        END IF;

        INSERT INTO usuarios (nombre_completo, email, password_hash, empresa_id, rol_id)
        VALUES (p_nombre, p_email, p_password_hash, v_empresa_id, v_rol_id)
        RETURNING id INTO v_user_id;

        RETURN jsonb_build_object(
            'id',     v_user_id,
            'nombre', p_nombre,
            'email',  p_email
        );

    END IF;

    RETURN jsonb_build_object('error', 'Acción no reconocida: ' || COALESCE(p_ac, 'NULL'));
END;
$$;


-- =============================================================
-- FUNCIÓN: public.read_usuarios
-- Maneja todas las lecturas sobre la tabla usuarios.
-- Parámetro AC (acción):
--   'login' → Devuelve datos del usuario + password_hash para verificación
--   'me'    → Devuelve datos del usuario autenticado (sin hash)
-- =============================================================
CREATE OR REPLACE FUNCTION public.read_usuarios(
    p_ac    TEXT,
    p_email TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_user RECORD;
BEGIN

    -- ── LOGIN ────────────────────────────────────────────────
    IF p_ac = 'login' THEN

        SELECT id, nombre_completo, email, password_hash, empresa_id
        INTO v_user
        FROM usuarios
        WHERE email = p_email
          AND is_active = TRUE;

        IF NOT FOUND THEN
            RETURN jsonb_build_object('error', 'Credenciales incorrectas');
        END IF;

        RETURN jsonb_build_object(
            'id',            v_user.id,
            'nombre',        v_user.nombre_completo,
            'email',         v_user.email,
            'password_hash', v_user.password_hash,
            'empresa_id',    v_user.empresa_id
        );

    -- ── ME ───────────────────────────────────────────────────
    ELSIF p_ac = 'me' THEN

        SELECT id, nombre_completo, email
        INTO v_user
        FROM usuarios
        WHERE email = p_email
          AND is_active = TRUE;

        IF NOT FOUND THEN
            RETURN jsonb_build_object('error', 'Usuario no encontrado');
        END IF;

        RETURN jsonb_build_object(
            'id',     v_user.id,
            'nombre', v_user.nombre_completo,
            'email',  v_user.email
        );

    END IF;

    RETURN jsonb_build_object('error', 'Acción no reconocida: ' || COALESCE(p_ac, 'NULL'));
END;
$$;
