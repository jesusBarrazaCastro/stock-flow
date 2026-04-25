-- ============================================================================
-- STOCK FLOW - Script de Creación de Base de Datos
-- Generado: 2026-04-18
-- Motor: PostgreSQL
-- Descripción: Esquema completo para soportar todas las pantallas del sistema
--              de gestión de inventario Stock Flow.
-- ============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- EXTENSIONES NECESARIAS
-- ────────────────────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "pgcrypto";   -- Para gen_random_uuid() si se necesita

-- ════════════════════════════════════════════════════════════════════════════
-- 1. TABLA: empresas
--    Pantallas: CompanyDetailsScreen, CompanySettingsScreen, ProfileScreen
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE empresas (
    id                  SERIAL PRIMARY KEY,
    razon_social        VARCHAR(255)    NOT NULL,
    nombre_comercial    VARCHAR(255),
    rfc                 VARCHAR(20)     UNIQUE,
    correo_electronico  VARCHAR(255),
    telefono_principal  VARCHAR(30),
    direccion_fiscal    TEXT,
    logo_url            TEXT,
    plan_suscripcion    VARCHAR(50)     NOT NULL DEFAULT 'FREE',  -- FREE, PRO, ENTERPRISE
    limite_almacenes    INTEGER         DEFAULT 1,
    fecha_registro_empresa TIMESTAMP   NOT NULL DEFAULT NOW(),
    dias_alerta_caducidad  INT          NOT NULL DEFAULT 30,

    -- Columnas de auditoría
    registro_fecha      TIMESTAMP       NOT NULL DEFAULT NOW(),
    registro_estado     BOOLEAN         NOT NULL DEFAULT TRUE,
    registro_usuario    INTEGER         -- FK a usuarios (se agrega constraint después)
);

COMMENT ON TABLE empresas IS 'Almacena la información de cada empresa/organización registrada en el sistema.';


-- ════════════════════════════════════════════════════════════════════════════
-- 2. TABLA: roles
--    Pantallas: UsersManagementScreen (Admin / Empleado)
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE roles (
    id                  SERIAL PRIMARY KEY,
    nombre              VARCHAR(50)     NOT NULL UNIQUE,   -- 'Admin', 'Empleado'
    descripcion         TEXT,
    permisos            JSONB           DEFAULT '{}',       -- Permisos granulares en JSON

    -- Columnas de auditoría
    registro_fecha      TIMESTAMP       NOT NULL DEFAULT NOW(),
    registro_estado     BOOLEAN         NOT NULL DEFAULT TRUE,
    registro_usuario    INTEGER
);

COMMENT ON TABLE roles IS 'Catálogo de roles del sistema con permisos configurables.';

-- Roles iniciales
INSERT INTO roles (nombre, descripcion, permisos) VALUES
    ('Admin',    'Acceso total a la configuración y todos los almacenes.',
     '{"all": true}'),
    ('Empleado', 'Acceso limitado al registro de inventario y consultas.',
     '{"inventory_read": true, "inventory_write": true, "reports_read": true}');


-- ════════════════════════════════════════════════════════════════════════════
-- 3. TABLA: usuarios
--    Pantallas: ProfileScreen, EditProfileScreen, UsersManagementScreen
--    Auth: FastAPI + JWT
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE usuarios (
    id                  SERIAL PRIMARY KEY,
    empresa_id          INTEGER         NOT NULL REFERENCES empresas(id),
    rol_id              INTEGER         NOT NULL REFERENCES roles(id),

    -- Datos de perfil
    nombre_completo     VARCHAR(255)    NOT NULL,
    email               VARCHAR(255)    NOT NULL UNIQUE,
    telefono            VARCHAR(30),
    avatar_url          TEXT,

    -- Autenticación JWT (FastAPI)
    password_hash       VARCHAR(255)    NOT NULL,           -- bcrypt / argon2 hash
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    is_verified         BOOLEAN         NOT NULL DEFAULT FALSE,
    last_login          TIMESTAMP,
    refresh_token       TEXT,                               -- JWT refresh token vigente
    refresh_token_exp   TIMESTAMP,                          -- Expiración del refresh token
    password_reset_token    VARCHAR(255),                   -- Token temporal para reset
    password_reset_exp      TIMESTAMP,                      -- Expiración del token de reset

    -- Columnas de auditoría
    registro_fecha      TIMESTAMP       NOT NULL DEFAULT NOW(),
    registro_estado     BOOLEAN         NOT NULL DEFAULT TRUE,
    registro_usuario    INTEGER         REFERENCES usuarios(id)
);

CREATE INDEX idx_usuarios_email       ON usuarios(email);
CREATE INDEX idx_usuarios_empresa_id  ON usuarios(empresa_id);

COMMENT ON TABLE usuarios IS 'Tabla principal de usuarios con autenticación JWT. Soporta perfil, roles y tokens.';


-- ════════════════════════════════════════════════════════════════════════════
-- FK retrasada: empresas.registro_usuario → usuarios.id
-- ════════════════════════════════════════════════════════════════════════════
ALTER TABLE empresas
    ADD CONSTRAINT fk_empresas_registro_usuario
    FOREIGN KEY (registro_usuario) REFERENCES usuarios(id);

ALTER TABLE roles
    ADD CONSTRAINT fk_roles_registro_usuario
    FOREIGN KEY (registro_usuario) REFERENCES usuarios(id);


-- ════════════════════════════════════════════════════════════════════════════
-- 4. TABLA: almacenes (sucursales)
--    Pantallas: CompanySettingsScreen (Sucursales y Almacenes),
--               CompanyDetailsScreen (Límite de Almacenes)
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE almacenes (
    id                  SERIAL PRIMARY KEY,
    empresa_id          INTEGER         NOT NULL REFERENCES empresas(id),
    nombre              VARCHAR(255)    NOT NULL,
    direccion           TEXT,
    telefono            VARCHAR(30),
    responsable_id      INTEGER         REFERENCES usuarios(id),
    capacidad_maxima    INTEGER,                            -- Capacidad máxima en unidades
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,

    -- Columnas de auditoría
    registro_fecha      TIMESTAMP       NOT NULL DEFAULT NOW(),
    registro_estado     BOOLEAN         NOT NULL DEFAULT TRUE,
    registro_usuario    INTEGER         REFERENCES usuarios(id)
);

CREATE INDEX idx_almacenes_empresa_id ON almacenes(empresa_id);

COMMENT ON TABLE almacenes IS 'Sucursales/almacenes de cada empresa. Dashboard muestra capacidad y unidades.';


-- ════════════════════════════════════════════════════════════════════════════
-- 5. TABLA: categorias
--    Pantallas: StockScreen (filtro por categoría: Mobiliario, Papelería,
--               Arte, Ediciones de Lujo)
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE categorias (
    id                  SERIAL PRIMARY KEY,
    nombre              VARCHAR(150)    NOT NULL UNIQUE,
    descripcion         TEXT,
    color_hex           VARCHAR(7),                         -- Color para la UI, ej: #4DB6AC

    -- Columnas de auditoría
    registro_fecha      TIMESTAMP       NOT NULL DEFAULT NOW(),
    registro_estado     BOOLEAN         NOT NULL DEFAULT TRUE,
    registro_usuario    INTEGER         REFERENCES usuarios(id)
);

COMMENT ON TABLE categorias IS 'Categorías de productos configurables por empresa.';


-- ════════════════════════════════════════════════════════════════════════════
-- 6. TABLA: proveedores
--    Pantallas: StockScreen (Gestión de Proveedores),
--               ManualRegistrationScreen (Proveedor / Origen dropdown)
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE proveedores (
    id                  SERIAL PRIMARY KEY,
    empresa_id          INTEGER         NOT NULL REFERENCES empresas(id),
    nombre              VARCHAR(255)    NOT NULL,
    contacto_nombre     VARCHAR(255),
    contacto_email      VARCHAR(255),
    contacto_telefono   VARCHAR(30),
    direccion           TEXT,
    notas               TEXT,

    -- Columnas de auditoría
    registro_fecha      TIMESTAMP       NOT NULL DEFAULT NOW(),
    registro_estado     BOOLEAN         NOT NULL DEFAULT TRUE,
    registro_usuario    INTEGER         REFERENCES usuarios(id)
);

CREATE INDEX idx_proveedores_empresa_id ON proveedores(empresa_id);

COMMENT ON TABLE proveedores IS 'Directorio de proveedores por empresa.';


-- ════════════════════════════════════════════════════════════════════════════
-- 7. TABLA: productos
--    Pantallas: StockScreen (listado de existencias con SKU, categoría,
--               cantidad, status), DashboardScreen (inventario total,
--               productos top, smart insights)
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE productos (
    id                  SERIAL PRIMARY KEY,
    empresa_id          INTEGER         NOT NULL REFERENCES empresas(id),
    categoria_id        INTEGER         REFERENCES categorias(id),
    proveedor_id        INTEGER         REFERENCES proveedores(id),

    nombre              VARCHAR(255)    NOT NULL,
    sku                 VARCHAR(50)     NOT NULL,
    descripcion         TEXT,
    precio_unitario     NUMERIC(12, 2)  DEFAULT 0.00,
    imagen_url          TEXT,
    unidad_medida       VARCHAR(30)     DEFAULT 'unidad',   -- unidad, kg, litro, etc.

    -- Niveles de stock
    stock_minimo        INTEGER         DEFAULT 0,          -- Umbral para "Stock Bajo"
    stock_maximo        INTEGER,                            -- Umbral para "Exceso"
    tiene_caducidad     BOOLEAN         NOT NULL DEFAULT FALSE,

    -- Columnas de auditoría
    registro_fecha      TIMESTAMP       NOT NULL DEFAULT NOW(),
    registro_estado     BOOLEAN         NOT NULL DEFAULT TRUE,
    registro_usuario    INTEGER         REFERENCES usuarios(id),

    UNIQUE(empresa_id, sku)
);

CREATE INDEX idx_productos_empresa_id   ON productos(empresa_id);
CREATE INDEX idx_productos_categoria_id ON productos(categoria_id);
CREATE INDEX idx_productos_sku          ON productos(sku);

COMMENT ON TABLE productos IS 'Catálogo maestro de productos con SKU, precios y umbrales de stock.';


-- ════════════════════════════════════════════════════════════════════════════
-- 8. TABLA: inventario
--    Pantallas: StockScreen (existencias por almacén),
--               DashboardScreen (inventario total, capacidad, estado crítico)
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE inventario (
    id                  SERIAL PRIMARY KEY,
    producto_id         INTEGER         NOT NULL REFERENCES productos(id),
    almacen_id          INTEGER         NOT NULL REFERENCES almacenes(id),
    cantidad_actual     INTEGER         NOT NULL DEFAULT 0,
    ubicacion_fisica    VARCHAR(100),                       -- Ej: Pasillo A, Estante 3

    -- Columnas de auditoría
    registro_fecha      TIMESTAMP       NOT NULL DEFAULT NOW(),
    registro_estado     BOOLEAN         NOT NULL DEFAULT TRUE,
    registro_usuario    INTEGER         REFERENCES usuarios(id),

    UNIQUE(producto_id, almacen_id)
);

CREATE INDEX idx_inventario_producto_id ON inventario(producto_id);
CREATE INDEX idx_inventario_almacen_id  ON inventario(almacen_id);

COMMENT ON TABLE inventario IS 'Stock actual por producto y almacén. Es la fuente de verdad para existencias.';


-- ════════════════════════════════════════════════════════════════════════════
-- 9. TABLA: movimientos_inventario
--    Pantallas: ManualRegistrationScreen (Entrada/Salida con cantidad,
--               precio, proveedor, notas, fecha),
--               VoiceRegistrationScreen, CameraRegistrationScreen,
--               DashboardScreen (Actividad Reciente),
--               DataScreen (Flujo de Stock, Total Entradas/Salidas)
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE movimientos_inventario (
    id                  SERIAL PRIMARY KEY,
    producto_id         INTEGER         NOT NULL REFERENCES productos(id),
    almacen_id          INTEGER         NOT NULL REFERENCES almacenes(id),
    usuario_id          INTEGER         NOT NULL REFERENCES usuarios(id),
    proveedor_id        INTEGER         REFERENCES proveedores(id),

    tipo_movimiento     VARCHAR(10)     NOT NULL CHECK (tipo_movimiento IN ('ENTRADA', 'SALIDA')),
    cantidad            INTEGER         NOT NULL CHECK (cantidad > 0),
    precio_unitario     NUMERIC(12, 2),
    fecha_movimiento    TIMESTAMP       NOT NULL DEFAULT NOW(),
    notas               TEXT,

    -- Método de registro
    metodo_registro     VARCHAR(20)     NOT NULL DEFAULT 'MANUAL'
                        CHECK (metodo_registro IN ('MANUAL', 'VOZ', 'CAMARA')),
    -- Referencia al documento escaneado (cámara) o transcripción (voz)
    documento_url       TEXT,
    transcripcion_texto TEXT,
    fecha_caducidad     DATE,

    -- Columnas de auditoría
    registro_fecha      TIMESTAMP       NOT NULL DEFAULT NOW(),
    registro_estado     BOOLEAN         NOT NULL DEFAULT TRUE,
    registro_usuario    INTEGER         REFERENCES usuarios(id)
);

CREATE INDEX idx_movimientos_producto_id    ON movimientos_inventario(producto_id);
CREATE INDEX idx_movimientos_almacen_id     ON movimientos_inventario(almacen_id);
CREATE INDEX idx_movimientos_usuario_id     ON movimientos_inventario(usuario_id);
CREATE INDEX idx_movimientos_tipo           ON movimientos_inventario(tipo_movimiento);
CREATE INDEX idx_movimientos_fecha          ON movimientos_inventario(fecha_movimiento);
CREATE INDEX idx_movimientos_metodo         ON movimientos_inventario(metodo_registro);

COMMENT ON TABLE movimientos_inventario IS 'Registro de todos los movimientos de entrada/salida. Soporta registro manual, por voz y por cámara.';


-- ════════════════════════════════════════════════════════════════════════════
-- 10. TABLA: alertas_stock
--     Pantallas: DashboardScreen (Estado Crítico – 3 alertas,
--                "Acción requerida inmediata")
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE alertas_stock (
    id                  SERIAL PRIMARY KEY,
    producto_id         INTEGER         NOT NULL REFERENCES productos(id),
    almacen_id          INTEGER         NOT NULL REFERENCES almacenes(id),

    tipo_alerta         VARCHAR(20)     NOT NULL CHECK (tipo_alerta IN ('AGOTADO', 'STOCK_BAJO', 'EXCESO')),
    cantidad_actual     INTEGER         NOT NULL,
    umbral              INTEGER         NOT NULL,           -- El umbral que disparó la alerta
    mensaje             TEXT,
    is_resolved         BOOLEAN         NOT NULL DEFAULT FALSE,
    fecha_resolucion    TIMESTAMP,

    -- Columnas de auditoría
    registro_fecha      TIMESTAMP       NOT NULL DEFAULT NOW(),
    registro_estado     BOOLEAN         NOT NULL DEFAULT TRUE,
    registro_usuario    INTEGER         REFERENCES usuarios(id)
);

CREATE INDEX idx_alertas_producto_id ON alertas_stock(producto_id);
CREATE INDEX idx_alertas_tipo        ON alertas_stock(tipo_alerta);
CREATE INDEX idx_alertas_resolved    ON alertas_stock(is_resolved);

COMMENT ON TABLE alertas_stock IS 'Alertas automáticas cuando el stock cruza umbrales configurados.';


-- ════════════════════════════════════════════════════════════════════════════
-- 11. TABLA: reportes
--     Pantallas: DataScreen (Flujo de Stock semanal, Total Entradas,
--                Total Salidas, Valor Estimado, Productos Top)
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE reportes (
    id                  SERIAL PRIMARY KEY,
    empresa_id          INTEGER         NOT NULL REFERENCES empresas(id),
    generado_por_id     INTEGER         NOT NULL REFERENCES usuarios(id),

    tipo_reporte        VARCHAR(50)     NOT NULL,           -- 'flujo_stock', 'productos_top', 'valor_inventario'
    periodo_inicio      TIMESTAMP       NOT NULL,
    periodo_fin         TIMESTAMP       NOT NULL,
    datos               JSONB           NOT NULL DEFAULT '{}',  -- Datos del reporte en JSON
    formato             VARCHAR(10)     DEFAULT 'JSON',     -- JSON, PDF, CSV

    -- Columnas de auditoría
    registro_fecha      TIMESTAMP       NOT NULL DEFAULT NOW(),
    registro_estado     BOOLEAN         NOT NULL DEFAULT TRUE,
    registro_usuario    INTEGER         REFERENCES usuarios(id)
);

CREATE INDEX idx_reportes_empresa_id ON reportes(empresa_id);
CREATE INDEX idx_reportes_tipo       ON reportes(tipo_reporte);

COMMENT ON TABLE reportes IS 'Reportes generados del sistema (flujo de stock, productos top, valor estimado).';


-- ════════════════════════════════════════════════════════════════════════════
-- 12. TABLA: configuraciones_notificaciones
--     Pantallas: ProfileScreen (Notificaciones → Alertas de stock y reportes)
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE configuraciones_notificaciones (
    id                  SERIAL PRIMARY KEY,
    usuario_id          INTEGER         NOT NULL REFERENCES usuarios(id) UNIQUE,

    alerta_stock_bajo   BOOLEAN         NOT NULL DEFAULT TRUE,
    alerta_agotado      BOOLEAN         NOT NULL DEFAULT TRUE,
    alerta_exceso       BOOLEAN         NOT NULL DEFAULT FALSE,
    reporte_diario      BOOLEAN         NOT NULL DEFAULT FALSE,
    reporte_semanal     BOOLEAN         NOT NULL DEFAULT TRUE,
    push_enabled        BOOLEAN         NOT NULL DEFAULT TRUE,
    email_enabled       BOOLEAN         NOT NULL DEFAULT TRUE,

    -- Columnas de auditoría
    registro_fecha      TIMESTAMP       NOT NULL DEFAULT NOW(),
    registro_estado     BOOLEAN         NOT NULL DEFAULT TRUE,
    registro_usuario    INTEGER         REFERENCES usuarios(id)
);

COMMENT ON TABLE configuraciones_notificaciones IS 'Preferencias de notificación por usuario.';


-- ════════════════════════════════════════════════════════════════════════════
-- 13. TABLA: integraciones_api
--     Pantallas: CompanySettingsScreen (Integraciones y API –
--                Webhooks y conexiones externas)
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE integraciones_api (
    id                  SERIAL PRIMARY KEY,
    empresa_id          INTEGER         NOT NULL REFERENCES empresas(id),

    nombre              VARCHAR(150)    NOT NULL,
    tipo                VARCHAR(50)     NOT NULL,           -- 'webhook', 'rest_api', 'erp'
    url_endpoint        TEXT            NOT NULL,
    api_key_hash        VARCHAR(255),                       -- Hash de la API key
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    ultima_sincronizacion TIMESTAMP,
    config_extra        JSONB           DEFAULT '{}',

    -- Columnas de auditoría
    registro_fecha      TIMESTAMP       NOT NULL DEFAULT NOW(),
    registro_estado     BOOLEAN         NOT NULL DEFAULT TRUE,
    registro_usuario    INTEGER         REFERENCES usuarios(id)
);

CREATE INDEX idx_integraciones_empresa_id ON integraciones_api(empresa_id);

COMMENT ON TABLE integraciones_api IS 'Integraciones externas (webhooks, APIs, ERPs) configuradas por empresa.';


-- ════════════════════════════════════════════════════════════════════════════
-- 14. TABLA: log_actividad
--     Pantallas: DashboardScreen (Actividad Reciente – últimas entradas
--                y salidas con hora)
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE log_actividad (
    id                  SERIAL PRIMARY KEY,
    empresa_id          INTEGER         NOT NULL REFERENCES empresas(id),
    usuario_id          INTEGER         REFERENCES usuarios(id),

    accion              VARCHAR(100)    NOT NULL,           -- 'movimiento_entrada', 'movimiento_salida', 'login', etc.
    entidad             VARCHAR(100),                       -- 'productos', 'movimientos_inventario', etc.
    entidad_id          INTEGER,                            -- ID del registro afectado
    descripcion         TEXT,
    datos_extra         JSONB           DEFAULT '{}',
    ip_address          VARCHAR(45),
    user_agent          TEXT,

    -- Columnas de auditoría
    registro_fecha      TIMESTAMP       NOT NULL DEFAULT NOW(),
    registro_estado     BOOLEAN         NOT NULL DEFAULT TRUE,
    registro_usuario    INTEGER         REFERENCES usuarios(id)
);

CREATE INDEX idx_log_empresa_id  ON log_actividad(empresa_id);
CREATE INDEX idx_log_usuario_id  ON log_actividad(usuario_id);
CREATE INDEX idx_log_fecha       ON log_actividad(registro_fecha);
CREATE INDEX idx_log_accion      ON log_actividad(accion);

COMMENT ON TABLE log_actividad IS 'Bitácora de toda la actividad del sistema. Feed de Actividad Reciente del Dashboard.';


-- ════════════════════════════════════════════════════════════════════════════
-- 15. TABLA: suscripciones
--     Pantallas: CompanySettingsScreen (Suscripción – PLAN PRO, facturación)
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE suscripciones (
    id                  SERIAL PRIMARY KEY,
    empresa_id          INTEGER         NOT NULL REFERENCES empresas(id),

    plan                VARCHAR(50)     NOT NULL,           -- 'FREE', 'PRO', 'ENTERPRISE'
    tipo_facturacion    VARCHAR(20)     NOT NULL DEFAULT 'MENSUAL', -- 'MENSUAL', 'ANUAL'
    precio              NUMERIC(10, 2)  NOT NULL DEFAULT 0.00,
    fecha_inicio        TIMESTAMP       NOT NULL DEFAULT NOW(),
    fecha_fin           TIMESTAMP,
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    stripe_customer_id  VARCHAR(255),                       -- ID externo de pago
    stripe_subscription_id VARCHAR(255),

    -- Columnas de auditoría
    registro_fecha      TIMESTAMP       NOT NULL DEFAULT NOW(),
    registro_estado     BOOLEAN         NOT NULL DEFAULT TRUE,
    registro_usuario    INTEGER         REFERENCES usuarios(id)
);

CREATE INDEX idx_suscripciones_empresa_id ON suscripciones(empresa_id);

COMMENT ON TABLE suscripciones IS 'Historial y estado de suscripciones/planes por empresa.';


-- ════════════════════════════════════════════════════════════════════════════
-- VISTAS ÚTILES
-- ════════════════════════════════════════════════════════════════════════════

-- ── Vista: Stock actual por producto (para StockScreen) ──────────────────
CREATE OR REPLACE VIEW v_stock_productos AS
SELECT
    p.id                AS producto_id,
    p.empresa_id,
    p.nombre            AS producto_nombre,
    p.sku,
    c.nombre            AS categoria,
    p.precio_unitario,
    p.stock_minimo,
    p.stock_maximo,
    COALESCE(SUM(i.cantidad_actual), 0) AS stock_total,
    CASE
        WHEN COALESCE(SUM(i.cantidad_actual), 0) = 0 THEN 'AGOTADO'
        WHEN COALESCE(SUM(i.cantidad_actual), 0) <= p.stock_minimo THEN 'STOCK_BAJO'
        WHEN p.stock_maximo IS NOT NULL
             AND COALESCE(SUM(i.cantidad_actual), 0) >= p.stock_maximo THEN 'EXCESO'
        ELSE 'SUFICIENTE'
    END                 AS estado_stock
FROM productos p
LEFT JOIN categorias c ON c.id = p.categoria_id
LEFT JOIN inventario i ON i.producto_id = p.id AND i.registro_estado = TRUE
WHERE p.registro_estado = TRUE
GROUP BY p.id, p.empresa_id, p.nombre, p.sku, c.nombre,
         p.precio_unitario, p.stock_minimo, p.stock_maximo;

COMMENT ON VIEW v_stock_productos IS 'Stock total consolidado por producto con estado (AGOTADO, STOCK_BAJO, SUFICIENTE, EXCESO).';


-- ── Vista: Dashboard KPIs ────────────────────────────────────────────────
CREATE OR REPLACE VIEW v_dashboard_kpis AS
SELECT
    e.id                AS empresa_id,
    e.razon_social,
    COALESCE(SUM(i.cantidad_actual), 0)     AS inventario_total_unidades,
    COUNT(DISTINCT p.id)                    AS total_productos,
    COUNT(DISTINCT a.id)                    AS total_almacenes,
    (SELECT COUNT(*) FROM alertas_stock al
     JOIN productos pr ON pr.id = al.producto_id
     WHERE pr.empresa_id = e.id
       AND al.is_resolved = FALSE
       AND al.registro_estado = TRUE)       AS alertas_activas
FROM empresas e
LEFT JOIN almacenes a   ON a.empresa_id = e.id AND a.registro_estado = TRUE
LEFT JOIN productos p   ON p.empresa_id = e.id AND p.registro_estado = TRUE
LEFT JOIN inventario i  ON i.producto_id = p.id
                       AND i.almacen_id = a.id
                       AND i.registro_estado = TRUE
WHERE e.registro_estado = TRUE
GROUP BY e.id, e.razon_social;

COMMENT ON VIEW v_dashboard_kpis IS 'KPIs principales del Dashboard: inventario total, productos, almacenes y alertas.';


-- ── Vista: Actividad reciente (para DashboardScreen) ─────────────────────
CREATE OR REPLACE VIEW v_actividad_reciente AS
SELECT
    m.id,
    m.tipo_movimiento,
    m.cantidad,
    m.fecha_movimiento,
    m.metodo_registro,
    p.nombre            AS producto_nombre,
    p.sku,
    a.nombre            AS almacen_nombre,
    u.nombre_completo   AS usuario_nombre
FROM movimientos_inventario m
JOIN productos p    ON p.id = m.producto_id
JOIN almacenes a    ON a.id = m.almacen_id
JOIN usuarios u     ON u.id = m.usuario_id
WHERE m.registro_estado = TRUE
ORDER BY m.fecha_movimiento DESC;

COMMENT ON VIEW v_actividad_reciente IS 'Movimientos recientes formateados para el feed de Actividad Reciente.';


-- ── Vista: Productos Top (para DataScreen) ───────────────────────────────
CREATE OR REPLACE VIEW v_productos_top AS
SELECT
    p.id                AS producto_id,
    p.empresa_id,
    p.nombre            AS producto_nombre,
    SUM(CASE WHEN m.tipo_movimiento = 'SALIDA' THEN m.cantidad ELSE 0 END) AS total_salidas,
    SUM(CASE WHEN m.tipo_movimiento = 'ENTRADA' THEN m.cantidad ELSE 0 END) AS total_entradas,
    COUNT(m.id)         AS total_movimientos
FROM productos p
LEFT JOIN movimientos_inventario m ON m.producto_id = p.id AND m.registro_estado = TRUE
WHERE p.registro_estado = TRUE
GROUP BY p.id, p.empresa_id, p.nombre
ORDER BY total_salidas DESC;

COMMENT ON VIEW v_productos_top IS 'Ranking de productos por volumen de salidas (más demandados).';


-- ════════════════════════════════════════════════════════════════════════════
-- FIN DEL SCRIPT
-- ════════════════════════════════════════════════════════════════════════════
