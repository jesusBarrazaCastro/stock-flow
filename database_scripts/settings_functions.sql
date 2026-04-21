-- =============================================================
-- FUNCIÓN: public.read_usuarios (reemplaza la versión en auth_functions.sql)
-- Agrega la acción 'me_full' que devuelve datos completos del usuario.
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

    -- ── ME FULL ──────────────────────────────────────────────
    ELSIF p_ac = 'me_full' THEN

        SELECT u.id, u.nombre_completo, u.email, u.telefono,
               u.empresa_id, r.nombre AS rol_nombre, r.permisos
        INTO v_user
        FROM usuarios u
        JOIN roles r ON r.id = u.rol_id
        WHERE u.email = p_email
          AND u.is_active = TRUE;

        IF NOT FOUND THEN
            RETURN jsonb_build_object('error', 'Usuario no encontrado');
        END IF;

        RETURN jsonb_build_object(
            'id',          v_user.id,
            'nombre',      v_user.nombre_completo,
            'email',       v_user.email,
            'telefono',    v_user.telefono,
            'empresa_id',  v_user.empresa_id,
            'rol_nombre',  v_user.rol_nombre,
            'permisos',    v_user.permisos
        );

    END IF;

    RETURN jsonb_build_object('error', 'Acción no reconocida: ' || COALESCE(p_ac, 'NULL'));
END;
$$;


-- =============================================================
-- FUNCIÓN: public.write_perfil
-- Maneja escrituras sobre el perfil del usuario autenticado.
-- Parámetro AC (acción):
--   'update_profile' → Actualiza nombre y teléfono del usuario
-- =============================================================
CREATE OR REPLACE FUNCTION public.write_perfil(
    p_ac       TEXT,
    p_email    TEXT,
    p_nombre   TEXT DEFAULT NULL,
    p_telefono TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN

    -- ── UPDATE PROFILE ───────────────────────────────────────
    IF p_ac = 'update_profile' THEN

        UPDATE usuarios
        SET nombre_completo = COALESCE(NULLIF(p_nombre, ''), nombre_completo),
            telefono        = COALESCE(p_telefono, telefono)
        WHERE email = p_email
          AND is_active = TRUE;

        IF NOT FOUND THEN
            RETURN jsonb_build_object('error', 'Usuario no encontrado');
        END IF;

        RETURN jsonb_build_object('ok', true);

    END IF;

    RETURN jsonb_build_object('error', 'Acción no reconocida: ' || COALESCE(p_ac, 'NULL'));
END;
$$;


-- =============================================================
-- FUNCIÓN: public.read_empresas
-- Maneja lecturas sobre la tabla empresas.
-- Parámetro AC (acción):
--   'get' → Devuelve los datos editables de la empresa
-- =============================================================
CREATE OR REPLACE FUNCTION public.read_empresas(
    p_ac         TEXT,
    p_empresa_id INT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_empresa RECORD;
BEGIN

    -- ── GET ──────────────────────────────────────────────────
    IF p_ac = 'get' THEN

        SELECT id, razon_social, nombre_comercial, rfc,
               correo_electronico, telefono_principal,
               direccion_fiscal, plan_suscripcion, limite_almacenes,
               fecha_registro_empresa
        INTO v_empresa
        FROM empresas
        WHERE id = p_empresa_id
          AND registro_estado = TRUE;

        IF NOT FOUND THEN
            RETURN jsonb_build_object('error', 'Empresa no encontrada');
        END IF;

        RETURN jsonb_build_object(
            'id',                   v_empresa.id,
            'razon_social',         v_empresa.razon_social,
            'nombre_comercial',     v_empresa.nombre_comercial,
            'rfc',                  v_empresa.rfc,
            'correo_electronico',   v_empresa.correo_electronico,
            'telefono_principal',   v_empresa.telefono_principal,
            'direccion_fiscal',     v_empresa.direccion_fiscal,
            'plan_suscripcion',     v_empresa.plan_suscripcion,
            'limite_almacenes',     v_empresa.limite_almacenes,
            'fecha_registro',       to_char(v_empresa.fecha_registro_empresa, 'DD Mon YYYY')
        );

    END IF;

    RETURN jsonb_build_object('error', 'Acción no reconocida: ' || COALESCE(p_ac, 'NULL'));
END;
$$;


-- =============================================================
-- FUNCIÓN: public.write_empresas
-- Maneja escrituras sobre la tabla empresas.
-- Parámetro AC (acción):
--   'update' → Actualiza los datos editables de la empresa
-- =============================================================
CREATE OR REPLACE FUNCTION public.write_empresas(
    p_ac               TEXT,
    p_empresa_id       INT,
    p_razon_social     TEXT DEFAULT NULL,
    p_nombre_comercial TEXT DEFAULT NULL,
    p_rfc              TEXT DEFAULT NULL,
    p_correo           TEXT DEFAULT NULL,
    p_telefono         TEXT DEFAULT NULL,
    p_direccion        TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN

    -- ── UPDATE ───────────────────────────────────────────────
    IF p_ac = 'update' THEN

        UPDATE empresas
        SET razon_social       = COALESCE(NULLIF(p_razon_social, ''),     razon_social),
            nombre_comercial   = COALESCE(p_nombre_comercial,             nombre_comercial),
            rfc                = COALESCE(p_rfc,                          rfc),
            correo_electronico = COALESCE(p_correo,                       correo_electronico),
            telefono_principal = COALESCE(p_telefono,                     telefono_principal),
            direccion_fiscal   = COALESCE(p_direccion,                    direccion_fiscal)
        WHERE id = p_empresa_id
          AND registro_estado = TRUE;

        IF NOT FOUND THEN
            RETURN jsonb_build_object('error', 'Empresa no encontrada');
        END IF;

        RETURN jsonb_build_object('ok', true);

    END IF;

    RETURN jsonb_build_object('error', 'Acción no reconocida: ' || COALESCE(p_ac, 'NULL'));
END;
$$;
