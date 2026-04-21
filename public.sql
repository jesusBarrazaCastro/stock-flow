/*
 Navicat Premium Dump SQL

 Source Server         : stock_flow
 Source Server Type    : PostgreSQL
 Source Server Version : 170009 (170009)
 Source Host           : pg-stock-flow-stock-flow.b.aivencloud.com:12276
 Source Catalog        : defaultdb
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 170009 (170009)
 File Encoding         : 65001

 Date: 19/04/2026 23:36:27
*/


-- ----------------------------
-- Sequence structure for alertas_stock_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."alertas_stock_id_seq";
CREATE SEQUENCE "public"."alertas_stock_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;
ALTER SEQUENCE "public"."alertas_stock_id_seq" OWNER TO "avnadmin";

-- ----------------------------
-- Sequence structure for almacenes_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."almacenes_id_seq";
CREATE SEQUENCE "public"."almacenes_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;
ALTER SEQUENCE "public"."almacenes_id_seq" OWNER TO "avnadmin";

-- ----------------------------
-- Sequence structure for categorias_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."categorias_id_seq";
CREATE SEQUENCE "public"."categorias_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;
ALTER SEQUENCE "public"."categorias_id_seq" OWNER TO "avnadmin";

-- ----------------------------
-- Sequence structure for configuraciones_notificaciones_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."configuraciones_notificaciones_id_seq";
CREATE SEQUENCE "public"."configuraciones_notificaciones_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;
ALTER SEQUENCE "public"."configuraciones_notificaciones_id_seq" OWNER TO "avnadmin";

-- ----------------------------
-- Sequence structure for empresas_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."empresas_id_seq";
CREATE SEQUENCE "public"."empresas_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;
ALTER SEQUENCE "public"."empresas_id_seq" OWNER TO "avnadmin";

-- ----------------------------
-- Sequence structure for integraciones_api_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."integraciones_api_id_seq";
CREATE SEQUENCE "public"."integraciones_api_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;
ALTER SEQUENCE "public"."integraciones_api_id_seq" OWNER TO "avnadmin";

-- ----------------------------
-- Sequence structure for inventario_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."inventario_id_seq";
CREATE SEQUENCE "public"."inventario_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;
ALTER SEQUENCE "public"."inventario_id_seq" OWNER TO "avnadmin";

-- ----------------------------
-- Sequence structure for log_actividad_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."log_actividad_id_seq";
CREATE SEQUENCE "public"."log_actividad_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;
ALTER SEQUENCE "public"."log_actividad_id_seq" OWNER TO "avnadmin";

-- ----------------------------
-- Sequence structure for movimientos_inventario_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."movimientos_inventario_id_seq";
CREATE SEQUENCE "public"."movimientos_inventario_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;
ALTER SEQUENCE "public"."movimientos_inventario_id_seq" OWNER TO "avnadmin";

-- ----------------------------
-- Sequence structure for productos_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."productos_id_seq";
CREATE SEQUENCE "public"."productos_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;
ALTER SEQUENCE "public"."productos_id_seq" OWNER TO "avnadmin";

-- ----------------------------
-- Sequence structure for proveedores_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."proveedores_id_seq";
CREATE SEQUENCE "public"."proveedores_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;
ALTER SEQUENCE "public"."proveedores_id_seq" OWNER TO "avnadmin";

-- ----------------------------
-- Sequence structure for reportes_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."reportes_id_seq";
CREATE SEQUENCE "public"."reportes_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;
ALTER SEQUENCE "public"."reportes_id_seq" OWNER TO "avnadmin";

-- ----------------------------
-- Sequence structure for roles_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."roles_id_seq";
CREATE SEQUENCE "public"."roles_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;
ALTER SEQUENCE "public"."roles_id_seq" OWNER TO "avnadmin";

-- ----------------------------
-- Sequence structure for suscripciones_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."suscripciones_id_seq";
CREATE SEQUENCE "public"."suscripciones_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;
ALTER SEQUENCE "public"."suscripciones_id_seq" OWNER TO "avnadmin";

-- ----------------------------
-- Sequence structure for usuarios_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."usuarios_id_seq";
CREATE SEQUENCE "public"."usuarios_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;
ALTER SEQUENCE "public"."usuarios_id_seq" OWNER TO "avnadmin";

-- ----------------------------
-- Table structure for alertas_stock
-- ----------------------------
DROP TABLE IF EXISTS "public"."alertas_stock";
CREATE TABLE "public"."alertas_stock" (
  "id" int4 NOT NULL DEFAULT nextval('alertas_stock_id_seq'::regclass),
  "producto_id" int4 NOT NULL,
  "almacen_id" int4 NOT NULL,
  "tipo_alerta" varchar(20) COLLATE "pg_catalog"."default" NOT NULL,
  "cantidad_actual" int4 NOT NULL,
  "umbral" int4 NOT NULL,
  "mensaje" text COLLATE "pg_catalog"."default",
  "is_resolved" bool NOT NULL DEFAULT false,
  "fecha_resolucion" timestamp(6),
  "registro_fecha" timestamp(6) NOT NULL DEFAULT now(),
  "registro_estado" bool NOT NULL DEFAULT true,
  "registro_usuario" int4
)
;
ALTER TABLE "public"."alertas_stock" OWNER TO "avnadmin";
COMMENT ON TABLE "public"."alertas_stock" IS 'Alertas automáticas cuando el stock cruza umbrales configurados.';

-- ----------------------------
-- Table structure for almacenes
-- ----------------------------
DROP TABLE IF EXISTS "public"."almacenes";
CREATE TABLE "public"."almacenes" (
  "id" int4 NOT NULL DEFAULT nextval('almacenes_id_seq'::regclass),
  "empresa_id" int4 NOT NULL,
  "nombre" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "direccion" text COLLATE "pg_catalog"."default",
  "telefono" varchar(30) COLLATE "pg_catalog"."default",
  "responsable_id" int4,
  "capacidad_maxima" int4,
  "is_active" bool NOT NULL DEFAULT true,
  "registro_fecha" timestamp(6) NOT NULL DEFAULT now(),
  "registro_estado" bool NOT NULL DEFAULT true,
  "registro_usuario" int4
)
;
ALTER TABLE "public"."almacenes" OWNER TO "avnadmin";
COMMENT ON TABLE "public"."almacenes" IS 'Sucursales/almacenes de cada empresa. Dashboard muestra capacidad y unidades.';

-- ----------------------------
-- Table structure for categorias
-- ----------------------------
DROP TABLE IF EXISTS "public"."categorias";
CREATE TABLE "public"."categorias" (
  "id" int4 NOT NULL DEFAULT nextval('categorias_id_seq'::regclass),
  "empresa_id" int4 NOT NULL,
  "nombre" varchar(150) COLLATE "pg_catalog"."default" NOT NULL,
  "descripcion" text COLLATE "pg_catalog"."default",
  "color_hex" varchar(7) COLLATE "pg_catalog"."default",
  "registro_fecha" timestamp(6) NOT NULL DEFAULT now(),
  "registro_estado" bool NOT NULL DEFAULT true,
  "registro_usuario" int4
)
;
ALTER TABLE "public"."categorias" OWNER TO "avnadmin";
COMMENT ON TABLE "public"."categorias" IS 'Categorías de productos configurables por empresa.';

-- ----------------------------
-- Table structure for configuraciones_notificaciones
-- ----------------------------
DROP TABLE IF EXISTS "public"."configuraciones_notificaciones";
CREATE TABLE "public"."configuraciones_notificaciones" (
  "id" int4 NOT NULL DEFAULT nextval('configuraciones_notificaciones_id_seq'::regclass),
  "usuario_id" int4 NOT NULL,
  "alerta_stock_bajo" bool NOT NULL DEFAULT true,
  "alerta_agotado" bool NOT NULL DEFAULT true,
  "alerta_exceso" bool NOT NULL DEFAULT false,
  "reporte_diario" bool NOT NULL DEFAULT false,
  "reporte_semanal" bool NOT NULL DEFAULT true,
  "push_enabled" bool NOT NULL DEFAULT true,
  "email_enabled" bool NOT NULL DEFAULT true,
  "registro_fecha" timestamp(6) NOT NULL DEFAULT now(),
  "registro_estado" bool NOT NULL DEFAULT true,
  "registro_usuario" int4
)
;
ALTER TABLE "public"."configuraciones_notificaciones" OWNER TO "avnadmin";
COMMENT ON TABLE "public"."configuraciones_notificaciones" IS 'Preferencias de notificación por usuario.';

-- ----------------------------
-- Table structure for empresas
-- ----------------------------
DROP TABLE IF EXISTS "public"."empresas";
CREATE TABLE "public"."empresas" (
  "id" int4 NOT NULL DEFAULT nextval('empresas_id_seq'::regclass),
  "razon_social" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "nombre_comercial" varchar(255) COLLATE "pg_catalog"."default",
  "rfc" varchar(20) COLLATE "pg_catalog"."default",
  "correo_electronico" varchar(255) COLLATE "pg_catalog"."default",
  "telefono_principal" varchar(30) COLLATE "pg_catalog"."default",
  "direccion_fiscal" text COLLATE "pg_catalog"."default",
  "logo_url" text COLLATE "pg_catalog"."default",
  "plan_suscripcion" varchar(50) COLLATE "pg_catalog"."default" NOT NULL DEFAULT 'FREE'::character varying,
  "limite_almacenes" int4 DEFAULT 1,
  "fecha_registro_empresa" timestamp(6) NOT NULL DEFAULT now(),
  "registro_fecha" timestamp(6) NOT NULL DEFAULT now(),
  "registro_estado" bool NOT NULL DEFAULT true,
  "registro_usuario" int4
)
;
ALTER TABLE "public"."empresas" OWNER TO "avnadmin";
COMMENT ON TABLE "public"."empresas" IS 'Almacena la información de cada empresa/organización registrada en el sistema.';

-- ----------------------------
-- Table structure for integraciones_api
-- ----------------------------
DROP TABLE IF EXISTS "public"."integraciones_api";
CREATE TABLE "public"."integraciones_api" (
  "id" int4 NOT NULL DEFAULT nextval('integraciones_api_id_seq'::regclass),
  "empresa_id" int4 NOT NULL,
  "nombre" varchar(150) COLLATE "pg_catalog"."default" NOT NULL,
  "tipo" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "url_endpoint" text COLLATE "pg_catalog"."default" NOT NULL,
  "api_key_hash" varchar(255) COLLATE "pg_catalog"."default",
  "is_active" bool NOT NULL DEFAULT true,
  "ultima_sincronizacion" timestamp(6),
  "config_extra" jsonb DEFAULT '{}'::jsonb,
  "registro_fecha" timestamp(6) NOT NULL DEFAULT now(),
  "registro_estado" bool NOT NULL DEFAULT true,
  "registro_usuario" int4
)
;
ALTER TABLE "public"."integraciones_api" OWNER TO "avnadmin";
COMMENT ON TABLE "public"."integraciones_api" IS 'Integraciones externas (webhooks, APIs, ERPs) configuradas por empresa.';

-- ----------------------------
-- Table structure for inventario
-- ----------------------------
DROP TABLE IF EXISTS "public"."inventario";
CREATE TABLE "public"."inventario" (
  "id" int4 NOT NULL DEFAULT nextval('inventario_id_seq'::regclass),
  "producto_id" int4 NOT NULL,
  "almacen_id" int4 NOT NULL,
  "cantidad_actual" int4 NOT NULL DEFAULT 0,
  "ubicacion_fisica" varchar(100) COLLATE "pg_catalog"."default",
  "registro_fecha" timestamp(6) NOT NULL DEFAULT now(),
  "registro_estado" bool NOT NULL DEFAULT true,
  "registro_usuario" int4
)
;
ALTER TABLE "public"."inventario" OWNER TO "avnadmin";
COMMENT ON TABLE "public"."inventario" IS 'Stock actual por producto y almacén. Es la fuente de verdad para existencias.';

-- ----------------------------
-- Table structure for log_actividad
-- ----------------------------
DROP TABLE IF EXISTS "public"."log_actividad";
CREATE TABLE "public"."log_actividad" (
  "id" int4 NOT NULL DEFAULT nextval('log_actividad_id_seq'::regclass),
  "empresa_id" int4 NOT NULL,
  "usuario_id" int4,
  "accion" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
  "entidad" varchar(100) COLLATE "pg_catalog"."default",
  "entidad_id" int4,
  "descripcion" text COLLATE "pg_catalog"."default",
  "datos_extra" jsonb DEFAULT '{}'::jsonb,
  "ip_address" varchar(45) COLLATE "pg_catalog"."default",
  "user_agent" text COLLATE "pg_catalog"."default",
  "registro_fecha" timestamp(6) NOT NULL DEFAULT now(),
  "registro_estado" bool NOT NULL DEFAULT true,
  "registro_usuario" int4
)
;
ALTER TABLE "public"."log_actividad" OWNER TO "avnadmin";
COMMENT ON TABLE "public"."log_actividad" IS 'Bitácora de toda la actividad del sistema. Feed de Actividad Reciente del Dashboard.';

-- ----------------------------
-- Table structure for movimientos_inventario
-- ----------------------------
DROP TABLE IF EXISTS "public"."movimientos_inventario";
CREATE TABLE "public"."movimientos_inventario" (
  "id" int4 NOT NULL DEFAULT nextval('movimientos_inventario_id_seq'::regclass),
  "producto_id" int4 NOT NULL,
  "almacen_id" int4 NOT NULL,
  "usuario_id" int4 NOT NULL,
  "proveedor_id" int4,
  "tipo_movimiento" varchar(10) COLLATE "pg_catalog"."default" NOT NULL,
  "cantidad" int4 NOT NULL,
  "precio_unitario" numeric(12,2),
  "fecha_movimiento" timestamp(6) NOT NULL DEFAULT now(),
  "notas" text COLLATE "pg_catalog"."default",
  "metodo_registro" varchar(20) COLLATE "pg_catalog"."default" NOT NULL DEFAULT 'MANUAL'::character varying,
  "documento_url" text COLLATE "pg_catalog"."default",
  "transcripcion_texto" text COLLATE "pg_catalog"."default",
  "registro_fecha" timestamp(6) NOT NULL DEFAULT now(),
  "registro_estado" bool NOT NULL DEFAULT true,
  "registro_usuario" int4
)
;
ALTER TABLE "public"."movimientos_inventario" OWNER TO "avnadmin";
COMMENT ON TABLE "public"."movimientos_inventario" IS 'Registro de todos los movimientos de entrada/salida. Soporta registro manual, por voz y por cámara.';

-- ----------------------------
-- Table structure for productos
-- ----------------------------
DROP TABLE IF EXISTS "public"."productos";
CREATE TABLE "public"."productos" (
  "id" int4 NOT NULL DEFAULT nextval('productos_id_seq'::regclass),
  "empresa_id" int4 NOT NULL,
  "categoria_id" int4,
  "proveedor_id" int4,
  "nombre" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "sku" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "descripcion" text COLLATE "pg_catalog"."default",
  "precio_unitario" numeric(12,2) DEFAULT 0.00,
  "imagen_url" text COLLATE "pg_catalog"."default",
  "unidad_medida" varchar(30) COLLATE "pg_catalog"."default" DEFAULT 'unidad'::character varying,
  "stock_minimo" int4 DEFAULT 0,
  "stock_maximo" int4,
  "registro_fecha" timestamp(6) NOT NULL DEFAULT now(),
  "registro_estado" bool NOT NULL DEFAULT true,
  "registro_usuario" int4
)
;
ALTER TABLE "public"."productos" OWNER TO "avnadmin";
COMMENT ON TABLE "public"."productos" IS 'Catálogo maestro de productos con SKU, precios y umbrales de stock.';

-- ----------------------------
-- Table structure for proveedores
-- ----------------------------
DROP TABLE IF EXISTS "public"."proveedores";
CREATE TABLE "public"."proveedores" (
  "id" int4 NOT NULL DEFAULT nextval('proveedores_id_seq'::regclass),
  "empresa_id" int4 NOT NULL,
  "nombre" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "contacto_nombre" varchar(255) COLLATE "pg_catalog"."default",
  "contacto_email" varchar(255) COLLATE "pg_catalog"."default",
  "contacto_telefono" varchar(30) COLLATE "pg_catalog"."default",
  "direccion" text COLLATE "pg_catalog"."default",
  "notas" text COLLATE "pg_catalog"."default",
  "registro_fecha" timestamp(6) NOT NULL DEFAULT now(),
  "registro_estado" bool NOT NULL DEFAULT true,
  "registro_usuario" int4
)
;
ALTER TABLE "public"."proveedores" OWNER TO "avnadmin";
COMMENT ON TABLE "public"."proveedores" IS 'Directorio de proveedores por empresa.';

-- ----------------------------
-- Table structure for reportes
-- ----------------------------
DROP TABLE IF EXISTS "public"."reportes";
CREATE TABLE "public"."reportes" (
  "id" int4 NOT NULL DEFAULT nextval('reportes_id_seq'::regclass),
  "empresa_id" int4 NOT NULL,
  "generado_por_id" int4 NOT NULL,
  "tipo_reporte" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "periodo_inicio" timestamp(6) NOT NULL,
  "periodo_fin" timestamp(6) NOT NULL,
  "datos" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "formato" varchar(10) COLLATE "pg_catalog"."default" DEFAULT 'JSON'::character varying,
  "registro_fecha" timestamp(6) NOT NULL DEFAULT now(),
  "registro_estado" bool NOT NULL DEFAULT true,
  "registro_usuario" int4
)
;
ALTER TABLE "public"."reportes" OWNER TO "avnadmin";
COMMENT ON TABLE "public"."reportes" IS 'Reportes generados del sistema (flujo de stock, productos top, valor estimado).';

-- ----------------------------
-- Table structure for roles
-- ----------------------------
DROP TABLE IF EXISTS "public"."roles";
CREATE TABLE "public"."roles" (
  "id" int4 NOT NULL DEFAULT nextval('roles_id_seq'::regclass),
  "nombre" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "descripcion" text COLLATE "pg_catalog"."default",
  "permisos" jsonb DEFAULT '{}'::jsonb,
  "registro_fecha" timestamp(6) NOT NULL DEFAULT now(),
  "registro_estado" bool NOT NULL DEFAULT true,
  "registro_usuario" int4
)
;
ALTER TABLE "public"."roles" OWNER TO "avnadmin";
COMMENT ON TABLE "public"."roles" IS 'Catálogo de roles del sistema con permisos configurables.';

-- ----------------------------
-- Table structure for suscripciones
-- ----------------------------
DROP TABLE IF EXISTS "public"."suscripciones";
CREATE TABLE "public"."suscripciones" (
  "id" int4 NOT NULL DEFAULT nextval('suscripciones_id_seq'::regclass),
  "empresa_id" int4 NOT NULL,
  "plan" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
  "tipo_facturacion" varchar(20) COLLATE "pg_catalog"."default" NOT NULL DEFAULT 'MENSUAL'::character varying,
  "precio" numeric(10,2) NOT NULL DEFAULT 0.00,
  "fecha_inicio" timestamp(6) NOT NULL DEFAULT now(),
  "fecha_fin" timestamp(6),
  "is_active" bool NOT NULL DEFAULT true,
  "stripe_customer_id" varchar(255) COLLATE "pg_catalog"."default",
  "stripe_subscription_id" varchar(255) COLLATE "pg_catalog"."default",
  "registro_fecha" timestamp(6) NOT NULL DEFAULT now(),
  "registro_estado" bool NOT NULL DEFAULT true,
  "registro_usuario" int4
)
;
ALTER TABLE "public"."suscripciones" OWNER TO "avnadmin";
COMMENT ON TABLE "public"."suscripciones" IS 'Historial y estado de suscripciones/planes por empresa.';

-- ----------------------------
-- Table structure for usuarios
-- ----------------------------
DROP TABLE IF EXISTS "public"."usuarios";
CREATE TABLE "public"."usuarios" (
  "id" int4 NOT NULL DEFAULT nextval('usuarios_id_seq'::regclass),
  "empresa_id" int4 NOT NULL,
  "rol_id" int4 NOT NULL,
  "nombre_completo" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "email" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "telefono" varchar(30) COLLATE "pg_catalog"."default",
  "avatar_url" text COLLATE "pg_catalog"."default",
  "password_hash" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "is_active" bool NOT NULL DEFAULT true,
  "is_verified" bool NOT NULL DEFAULT false,
  "last_login" timestamp(6),
  "refresh_token" text COLLATE "pg_catalog"."default",
  "refresh_token_exp" timestamp(6),
  "password_reset_token" varchar(255) COLLATE "pg_catalog"."default",
  "password_reset_exp" timestamp(6),
  "registro_fecha" timestamp(6) NOT NULL DEFAULT now(),
  "registro_estado" bool NOT NULL DEFAULT true,
  "registro_usuario" int4
)
;
ALTER TABLE "public"."usuarios" OWNER TO "avnadmin";
COMMENT ON TABLE "public"."usuarios" IS 'Tabla principal de usuarios con autenticación JWT. Soporta perfil, roles y tokens.';

-- ----------------------------
-- Function structure for armor
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."armor"(bytea);
CREATE OR REPLACE FUNCTION "public"."armor"(bytea)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pg_armor'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."armor"(bytea) OWNER TO "postgres";

-- ----------------------------
-- Function structure for armor
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."armor"(bytea, _text, _text);
CREATE OR REPLACE FUNCTION "public"."armor"(bytea, _text, _text)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pg_armor'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."armor"(bytea, _text, _text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for crypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."crypt"(text, text);
CREATE OR REPLACE FUNCTION "public"."crypt"(text, text)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pg_crypt'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."crypt"(text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for dearmor
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."dearmor"(text);
CREATE OR REPLACE FUNCTION "public"."dearmor"(text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_dearmor'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."dearmor"(text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for decrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."decrypt"(bytea, bytea, text);
CREATE OR REPLACE FUNCTION "public"."decrypt"(bytea, bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_decrypt'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."decrypt"(bytea, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for decrypt_iv
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."decrypt_iv"(bytea, bytea, bytea, text);
CREATE OR REPLACE FUNCTION "public"."decrypt_iv"(bytea, bytea, bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_decrypt_iv'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."decrypt_iv"(bytea, bytea, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for digest
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."digest"(bytea, text);
CREATE OR REPLACE FUNCTION "public"."digest"(bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_digest'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."digest"(bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for digest
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."digest"(text, text);
CREATE OR REPLACE FUNCTION "public"."digest"(text, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_digest'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."digest"(text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for encrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."encrypt"(bytea, bytea, text);
CREATE OR REPLACE FUNCTION "public"."encrypt"(bytea, bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_encrypt'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."encrypt"(bytea, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for encrypt_iv
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."encrypt_iv"(bytea, bytea, bytea, text);
CREATE OR REPLACE FUNCTION "public"."encrypt_iv"(bytea, bytea, bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_encrypt_iv'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."encrypt_iv"(bytea, bytea, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for gen_random_bytes
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."gen_random_bytes"(int4);
CREATE OR REPLACE FUNCTION "public"."gen_random_bytes"(int4)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_random_bytes'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."gen_random_bytes"(int4) OWNER TO "postgres";

-- ----------------------------
-- Function structure for gen_random_uuid
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."gen_random_uuid"();
CREATE OR REPLACE FUNCTION "public"."gen_random_uuid"()
  RETURNS "pg_catalog"."uuid" AS '$libdir/pgcrypto', 'pg_random_uuid'
  LANGUAGE c VOLATILE
  COST 1;
ALTER FUNCTION "public"."gen_random_uuid"() OWNER TO "postgres";

-- ----------------------------
-- Function structure for gen_salt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."gen_salt"(text, int4);
CREATE OR REPLACE FUNCTION "public"."gen_salt"(text, int4)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pg_gen_salt_rounds'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."gen_salt"(text, int4) OWNER TO "postgres";

-- ----------------------------
-- Function structure for gen_salt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."gen_salt"(text);
CREATE OR REPLACE FUNCTION "public"."gen_salt"(text)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pg_gen_salt'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."gen_salt"(text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for hmac
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."hmac"(text, text, text);
CREATE OR REPLACE FUNCTION "public"."hmac"(text, text, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_hmac'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."hmac"(text, text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for hmac
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."hmac"(bytea, bytea, text);
CREATE OR REPLACE FUNCTION "public"."hmac"(bytea, bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pg_hmac'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."hmac"(bytea, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_armor_headers
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_armor_headers"(text, OUT "key" text, OUT "value" text);
CREATE OR REPLACE FUNCTION "public"."pgp_armor_headers"(IN text, OUT "key" text, OUT "value" text)
  RETURNS SETOF "pg_catalog"."record" AS '$libdir/pgcrypto', 'pgp_armor_headers'
  LANGUAGE c IMMUTABLE STRICT
  COST 1
  ROWS 1000;
ALTER FUNCTION "public"."pgp_armor_headers"(text, OUT "key" text, OUT "value" text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_key_id
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_key_id"(bytea);
CREATE OR REPLACE FUNCTION "public"."pgp_key_id"(bytea)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pgp_key_id_w'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_key_id"(bytea) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_decrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_decrypt"(bytea, bytea, text);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_decrypt"(bytea, bytea, text)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_decrypt"(bytea, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_decrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_decrypt"(bytea, bytea);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_decrypt"(bytea, bytea)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_decrypt"(bytea, bytea) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_decrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_decrypt"(bytea, bytea, text, text);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_decrypt"(bytea, bytea, text, text)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_decrypt"(bytea, bytea, text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_decrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_decrypt_bytea"(bytea, bytea, text);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_decrypt_bytea"(bytea, bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_decrypt_bytea"(bytea, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_decrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_decrypt_bytea"(bytea, bytea, text, text);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_decrypt_bytea"(bytea, bytea, text, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_decrypt_bytea"(bytea, bytea, text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_decrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_decrypt_bytea"(bytea, bytea);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_decrypt_bytea"(bytea, bytea)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_decrypt_bytea"(bytea, bytea) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_encrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_encrypt"(text, bytea);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_encrypt"(text, bytea)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_pub_encrypt_text'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_encrypt"(text, bytea) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_encrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_encrypt"(text, bytea, text);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_encrypt"(text, bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_pub_encrypt_text'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_encrypt"(text, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_encrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_encrypt_bytea"(bytea, bytea, text);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_encrypt_bytea"(bytea, bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_pub_encrypt_bytea'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_encrypt_bytea"(bytea, bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_pub_encrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_pub_encrypt_bytea"(bytea, bytea);
CREATE OR REPLACE FUNCTION "public"."pgp_pub_encrypt_bytea"(bytea, bytea)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_pub_encrypt_bytea'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_pub_encrypt_bytea"(bytea, bytea) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_sym_decrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_sym_decrypt"(bytea, text);
CREATE OR REPLACE FUNCTION "public"."pgp_sym_decrypt"(bytea, text)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pgp_sym_decrypt_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_sym_decrypt"(bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_sym_decrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_sym_decrypt"(bytea, text, text);
CREATE OR REPLACE FUNCTION "public"."pgp_sym_decrypt"(bytea, text, text)
  RETURNS "pg_catalog"."text" AS '$libdir/pgcrypto', 'pgp_sym_decrypt_text'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_sym_decrypt"(bytea, text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_sym_decrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_sym_decrypt_bytea"(bytea, text, text);
CREATE OR REPLACE FUNCTION "public"."pgp_sym_decrypt_bytea"(bytea, text, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_sym_decrypt_bytea'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_sym_decrypt_bytea"(bytea, text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_sym_decrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_sym_decrypt_bytea"(bytea, text);
CREATE OR REPLACE FUNCTION "public"."pgp_sym_decrypt_bytea"(bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_sym_decrypt_bytea'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_sym_decrypt_bytea"(bytea, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_sym_encrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_sym_encrypt"(text, text, text);
CREATE OR REPLACE FUNCTION "public"."pgp_sym_encrypt"(text, text, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_sym_encrypt_text'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_sym_encrypt"(text, text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_sym_encrypt
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_sym_encrypt"(text, text);
CREATE OR REPLACE FUNCTION "public"."pgp_sym_encrypt"(text, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_sym_encrypt_text'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_sym_encrypt"(text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_sym_encrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_sym_encrypt_bytea"(bytea, text, text);
CREATE OR REPLACE FUNCTION "public"."pgp_sym_encrypt_bytea"(bytea, text, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_sym_encrypt_bytea'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_sym_encrypt_bytea"(bytea, text, text) OWNER TO "postgres";

-- ----------------------------
-- Function structure for pgp_sym_encrypt_bytea
-- ----------------------------
DROP FUNCTION IF EXISTS "public"."pgp_sym_encrypt_bytea"(bytea, text);
CREATE OR REPLACE FUNCTION "public"."pgp_sym_encrypt_bytea"(bytea, text)
  RETURNS "pg_catalog"."bytea" AS '$libdir/pgcrypto', 'pgp_sym_encrypt_bytea'
  LANGUAGE c VOLATILE STRICT
  COST 1;
ALTER FUNCTION "public"."pgp_sym_encrypt_bytea"(bytea, text) OWNER TO "postgres";

-- ----------------------------
-- View structure for v_stock_productos
-- ----------------------------
DROP VIEW IF EXISTS "public"."v_stock_productos";
CREATE VIEW "public"."v_stock_productos" AS  SELECT p.id AS producto_id,
    p.empresa_id,
    p.nombre AS producto_nombre,
    p.sku,
    c.nombre AS categoria,
    p.precio_unitario,
    p.stock_minimo,
    p.stock_maximo,
    COALESCE(sum(i.cantidad_actual), 0::bigint) AS stock_total,
        CASE
            WHEN COALESCE(sum(i.cantidad_actual), 0::bigint) = 0 THEN 'AGOTADO'::text
            WHEN COALESCE(sum(i.cantidad_actual), 0::bigint) <= p.stock_minimo THEN 'STOCK_BAJO'::text
            WHEN p.stock_maximo IS NOT NULL AND COALESCE(sum(i.cantidad_actual), 0::bigint) >= p.stock_maximo THEN 'EXCESO'::text
            ELSE 'SUFICIENTE'::text
        END AS estado_stock
   FROM productos p
     LEFT JOIN categorias c ON c.id = p.categoria_id
     LEFT JOIN inventario i ON i.producto_id = p.id AND i.registro_estado = true
  WHERE p.registro_estado = true
  GROUP BY p.id, p.empresa_id, p.nombre, p.sku, c.nombre, p.precio_unitario, p.stock_minimo, p.stock_maximo;
ALTER TABLE "public"."v_stock_productos" OWNER TO "avnadmin";
COMMENT ON VIEW "public"."v_stock_productos" IS 'Stock total consolidado por producto con estado (AGOTADO, STOCK_BAJO, SUFICIENTE, EXCESO).';

-- ----------------------------
-- View structure for v_dashboard_kpis
-- ----------------------------
DROP VIEW IF EXISTS "public"."v_dashboard_kpis";
CREATE VIEW "public"."v_dashboard_kpis" AS  SELECT e.id AS empresa_id,
    e.razon_social,
    COALESCE(sum(i.cantidad_actual), 0::bigint) AS inventario_total_unidades,
    count(DISTINCT p.id) AS total_productos,
    count(DISTINCT a.id) AS total_almacenes,
    ( SELECT count(*) AS count
           FROM alertas_stock al
             JOIN productos pr ON pr.id = al.producto_id
          WHERE pr.empresa_id = e.id AND al.is_resolved = false AND al.registro_estado = true) AS alertas_activas
   FROM empresas e
     LEFT JOIN almacenes a ON a.empresa_id = e.id AND a.registro_estado = true
     LEFT JOIN productos p ON p.empresa_id = e.id AND p.registro_estado = true
     LEFT JOIN inventario i ON i.producto_id = p.id AND i.almacen_id = a.id AND i.registro_estado = true
  WHERE e.registro_estado = true
  GROUP BY e.id, e.razon_social;
ALTER TABLE "public"."v_dashboard_kpis" OWNER TO "avnadmin";
COMMENT ON VIEW "public"."v_dashboard_kpis" IS 'KPIs principales del Dashboard: inventario total, productos, almacenes y alertas.';

-- ----------------------------
-- View structure for v_actividad_reciente
-- ----------------------------
DROP VIEW IF EXISTS "public"."v_actividad_reciente";
CREATE VIEW "public"."v_actividad_reciente" AS  SELECT m.id,
    m.tipo_movimiento,
    m.cantidad,
    m.fecha_movimiento,
    m.metodo_registro,
    p.nombre AS producto_nombre,
    p.sku,
    a.nombre AS almacen_nombre,
    u.nombre_completo AS usuario_nombre
   FROM movimientos_inventario m
     JOIN productos p ON p.id = m.producto_id
     JOIN almacenes a ON a.id = m.almacen_id
     JOIN usuarios u ON u.id = m.usuario_id
  WHERE m.registro_estado = true
  ORDER BY m.fecha_movimiento DESC;
ALTER TABLE "public"."v_actividad_reciente" OWNER TO "avnadmin";
COMMENT ON VIEW "public"."v_actividad_reciente" IS 'Movimientos recientes formateados para el feed de Actividad Reciente.';

-- ----------------------------
-- View structure for v_productos_top
-- ----------------------------
DROP VIEW IF EXISTS "public"."v_productos_top";
CREATE VIEW "public"."v_productos_top" AS  SELECT p.id AS producto_id,
    p.empresa_id,
    p.nombre AS producto_nombre,
    sum(
        CASE
            WHEN m.tipo_movimiento::text = 'SALIDA'::text THEN m.cantidad
            ELSE 0
        END) AS total_salidas,
    sum(
        CASE
            WHEN m.tipo_movimiento::text = 'ENTRADA'::text THEN m.cantidad
            ELSE 0
        END) AS total_entradas,
    count(m.id) AS total_movimientos
   FROM productos p
     LEFT JOIN movimientos_inventario m ON m.producto_id = p.id AND m.registro_estado = true
  WHERE p.registro_estado = true
  GROUP BY p.id, p.empresa_id, p.nombre
  ORDER BY (sum(
        CASE
            WHEN m.tipo_movimiento::text = 'SALIDA'::text THEN m.cantidad
            ELSE 0
        END)) DESC;
ALTER TABLE "public"."v_productos_top" OWNER TO "avnadmin";
COMMENT ON VIEW "public"."v_productos_top" IS 'Ranking de productos por volumen de salidas (más demandados).';

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."alertas_stock_id_seq"
OWNED BY "public"."alertas_stock"."id";
SELECT setval('"public"."alertas_stock_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."almacenes_id_seq"
OWNED BY "public"."almacenes"."id";
SELECT setval('"public"."almacenes_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."categorias_id_seq"
OWNED BY "public"."categorias"."id";
SELECT setval('"public"."categorias_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."configuraciones_notificaciones_id_seq"
OWNED BY "public"."configuraciones_notificaciones"."id";
SELECT setval('"public"."configuraciones_notificaciones_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."empresas_id_seq"
OWNED BY "public"."empresas"."id";
SELECT setval('"public"."empresas_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."integraciones_api_id_seq"
OWNED BY "public"."integraciones_api"."id";
SELECT setval('"public"."integraciones_api_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."inventario_id_seq"
OWNED BY "public"."inventario"."id";
SELECT setval('"public"."inventario_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."log_actividad_id_seq"
OWNED BY "public"."log_actividad"."id";
SELECT setval('"public"."log_actividad_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."movimientos_inventario_id_seq"
OWNED BY "public"."movimientos_inventario"."id";
SELECT setval('"public"."movimientos_inventario_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."productos_id_seq"
OWNED BY "public"."productos"."id";
SELECT setval('"public"."productos_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."proveedores_id_seq"
OWNED BY "public"."proveedores"."id";
SELECT setval('"public"."proveedores_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."reportes_id_seq"
OWNED BY "public"."reportes"."id";
SELECT setval('"public"."reportes_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."roles_id_seq"
OWNED BY "public"."roles"."id";
SELECT setval('"public"."roles_id_seq"', 2, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."suscripciones_id_seq"
OWNED BY "public"."suscripciones"."id";
SELECT setval('"public"."suscripciones_id_seq"', 1, false);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."usuarios_id_seq"
OWNED BY "public"."usuarios"."id";
SELECT setval('"public"."usuarios_id_seq"', 1, true);

-- ----------------------------
-- Indexes structure for table alertas_stock
-- ----------------------------
CREATE INDEX "idx_alertas_producto_id" ON "public"."alertas_stock" USING btree (
  "producto_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE INDEX "idx_alertas_resolved" ON "public"."alertas_stock" USING btree (
  "is_resolved" "pg_catalog"."bool_ops" ASC NULLS LAST
);
CREATE INDEX "idx_alertas_tipo" ON "public"."alertas_stock" USING btree (
  "tipo_alerta" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Checks structure for table alertas_stock
-- ----------------------------
ALTER TABLE "public"."alertas_stock" ADD CONSTRAINT "alertas_stock_tipo_alerta_check" CHECK (tipo_alerta::text = ANY (ARRAY['AGOTADO'::character varying, 'STOCK_BAJO'::character varying, 'EXCESO'::character varying]::text[]));

-- ----------------------------
-- Primary Key structure for table alertas_stock
-- ----------------------------
ALTER TABLE "public"."alertas_stock" ADD CONSTRAINT "alertas_stock_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table almacenes
-- ----------------------------
CREATE INDEX "idx_almacenes_empresa_id" ON "public"."almacenes" USING btree (
  "empresa_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table almacenes
-- ----------------------------
ALTER TABLE "public"."almacenes" ADD CONSTRAINT "almacenes_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Uniques structure for table categorias
-- ----------------------------
ALTER TABLE "public"."categorias" ADD CONSTRAINT "categorias_empresa_id_nombre_key" UNIQUE ("empresa_id", "nombre");

-- ----------------------------
-- Primary Key structure for table categorias
-- ----------------------------
ALTER TABLE "public"."categorias" ADD CONSTRAINT "categorias_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Uniques structure for table configuraciones_notificaciones
-- ----------------------------
ALTER TABLE "public"."configuraciones_notificaciones" ADD CONSTRAINT "configuraciones_notificaciones_usuario_id_key" UNIQUE ("usuario_id");

-- ----------------------------
-- Primary Key structure for table configuraciones_notificaciones
-- ----------------------------
ALTER TABLE "public"."configuraciones_notificaciones" ADD CONSTRAINT "configuraciones_notificaciones_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Uniques structure for table empresas
-- ----------------------------
ALTER TABLE "public"."empresas" ADD CONSTRAINT "empresas_rfc_key" UNIQUE ("rfc");

-- ----------------------------
-- Primary Key structure for table empresas
-- ----------------------------
ALTER TABLE "public"."empresas" ADD CONSTRAINT "empresas_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table integraciones_api
-- ----------------------------
CREATE INDEX "idx_integraciones_empresa_id" ON "public"."integraciones_api" USING btree (
  "empresa_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table integraciones_api
-- ----------------------------
ALTER TABLE "public"."integraciones_api" ADD CONSTRAINT "integraciones_api_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table inventario
-- ----------------------------
CREATE INDEX "idx_inventario_almacen_id" ON "public"."inventario" USING btree (
  "almacen_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE INDEX "idx_inventario_producto_id" ON "public"."inventario" USING btree (
  "producto_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);

-- ----------------------------
-- Uniques structure for table inventario
-- ----------------------------
ALTER TABLE "public"."inventario" ADD CONSTRAINT "inventario_producto_id_almacen_id_key" UNIQUE ("producto_id", "almacen_id");

-- ----------------------------
-- Primary Key structure for table inventario
-- ----------------------------
ALTER TABLE "public"."inventario" ADD CONSTRAINT "inventario_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table log_actividad
-- ----------------------------
CREATE INDEX "idx_log_accion" ON "public"."log_actividad" USING btree (
  "accion" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_log_empresa_id" ON "public"."log_actividad" USING btree (
  "empresa_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE INDEX "idx_log_fecha" ON "public"."log_actividad" USING btree (
  "registro_fecha" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);
CREATE INDEX "idx_log_usuario_id" ON "public"."log_actividad" USING btree (
  "usuario_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table log_actividad
-- ----------------------------
ALTER TABLE "public"."log_actividad" ADD CONSTRAINT "log_actividad_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table movimientos_inventario
-- ----------------------------
CREATE INDEX "idx_movimientos_almacen_id" ON "public"."movimientos_inventario" USING btree (
  "almacen_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE INDEX "idx_movimientos_fecha" ON "public"."movimientos_inventario" USING btree (
  "fecha_movimiento" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);
CREATE INDEX "idx_movimientos_metodo" ON "public"."movimientos_inventario" USING btree (
  "metodo_registro" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_movimientos_producto_id" ON "public"."movimientos_inventario" USING btree (
  "producto_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE INDEX "idx_movimientos_tipo" ON "public"."movimientos_inventario" USING btree (
  "tipo_movimiento" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_movimientos_usuario_id" ON "public"."movimientos_inventario" USING btree (
  "usuario_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);

-- ----------------------------
-- Checks structure for table movimientos_inventario
-- ----------------------------
ALTER TABLE "public"."movimientos_inventario" ADD CONSTRAINT "movimientos_inventario_cantidad_check" CHECK (cantidad > 0);
ALTER TABLE "public"."movimientos_inventario" ADD CONSTRAINT "movimientos_inventario_metodo_registro_check" CHECK (metodo_registro::text = ANY (ARRAY['MANUAL'::character varying, 'VOZ'::character varying, 'CAMARA'::character varying]::text[]));
ALTER TABLE "public"."movimientos_inventario" ADD CONSTRAINT "movimientos_inventario_tipo_movimiento_check" CHECK (tipo_movimiento::text = ANY (ARRAY['ENTRADA'::character varying, 'SALIDA'::character varying]::text[]));

-- ----------------------------
-- Primary Key structure for table movimientos_inventario
-- ----------------------------
ALTER TABLE "public"."movimientos_inventario" ADD CONSTRAINT "movimientos_inventario_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table productos
-- ----------------------------
CREATE INDEX "idx_productos_categoria_id" ON "public"."productos" USING btree (
  "categoria_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE INDEX "idx_productos_empresa_id" ON "public"."productos" USING btree (
  "empresa_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE INDEX "idx_productos_sku" ON "public"."productos" USING btree (
  "sku" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Uniques structure for table productos
-- ----------------------------
ALTER TABLE "public"."productos" ADD CONSTRAINT "productos_empresa_id_sku_key" UNIQUE ("empresa_id", "sku");

-- ----------------------------
-- Primary Key structure for table productos
-- ----------------------------
ALTER TABLE "public"."productos" ADD CONSTRAINT "productos_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table proveedores
-- ----------------------------
CREATE INDEX "idx_proveedores_empresa_id" ON "public"."proveedores" USING btree (
  "empresa_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table proveedores
-- ----------------------------
ALTER TABLE "public"."proveedores" ADD CONSTRAINT "proveedores_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table reportes
-- ----------------------------
CREATE INDEX "idx_reportes_empresa_id" ON "public"."reportes" USING btree (
  "empresa_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);
CREATE INDEX "idx_reportes_tipo" ON "public"."reportes" USING btree (
  "tipo_reporte" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table reportes
-- ----------------------------
ALTER TABLE "public"."reportes" ADD CONSTRAINT "reportes_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Uniques structure for table roles
-- ----------------------------
ALTER TABLE "public"."roles" ADD CONSTRAINT "roles_nombre_key" UNIQUE ("nombre");

-- ----------------------------
-- Primary Key structure for table roles
-- ----------------------------
ALTER TABLE "public"."roles" ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table suscripciones
-- ----------------------------
CREATE INDEX "idx_suscripciones_empresa_id" ON "public"."suscripciones" USING btree (
  "empresa_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table suscripciones
-- ----------------------------
ALTER TABLE "public"."suscripciones" ADD CONSTRAINT "suscripciones_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table usuarios
-- ----------------------------
CREATE INDEX "idx_usuarios_email" ON "public"."usuarios" USING btree (
  "email" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
CREATE INDEX "idx_usuarios_empresa_id" ON "public"."usuarios" USING btree (
  "empresa_id" "pg_catalog"."int4_ops" ASC NULLS LAST
);

-- ----------------------------
-- Uniques structure for table usuarios
-- ----------------------------
ALTER TABLE "public"."usuarios" ADD CONSTRAINT "usuarios_email_key" UNIQUE ("email");

-- ----------------------------
-- Primary Key structure for table usuarios
-- ----------------------------
ALTER TABLE "public"."usuarios" ADD CONSTRAINT "usuarios_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Foreign Keys structure for table alertas_stock
-- ----------------------------
ALTER TABLE "public"."alertas_stock" ADD CONSTRAINT "alertas_stock_almacen_id_fkey" FOREIGN KEY ("almacen_id") REFERENCES "public"."almacenes" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."alertas_stock" ADD CONSTRAINT "alertas_stock_producto_id_fkey" FOREIGN KEY ("producto_id") REFERENCES "public"."productos" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."alertas_stock" ADD CONSTRAINT "alertas_stock_registro_usuario_fkey" FOREIGN KEY ("registro_usuario") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table almacenes
-- ----------------------------
ALTER TABLE "public"."almacenes" ADD CONSTRAINT "almacenes_empresa_id_fkey" FOREIGN KEY ("empresa_id") REFERENCES "public"."empresas" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."almacenes" ADD CONSTRAINT "almacenes_registro_usuario_fkey" FOREIGN KEY ("registro_usuario") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."almacenes" ADD CONSTRAINT "almacenes_responsable_id_fkey" FOREIGN KEY ("responsable_id") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table categorias
-- ----------------------------
ALTER TABLE "public"."categorias" ADD CONSTRAINT "categorias_empresa_id_fkey" FOREIGN KEY ("empresa_id") REFERENCES "public"."empresas" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."categorias" ADD CONSTRAINT "categorias_registro_usuario_fkey" FOREIGN KEY ("registro_usuario") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table configuraciones_notificaciones
-- ----------------------------
ALTER TABLE "public"."configuraciones_notificaciones" ADD CONSTRAINT "configuraciones_notificaciones_registro_usuario_fkey" FOREIGN KEY ("registro_usuario") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."configuraciones_notificaciones" ADD CONSTRAINT "configuraciones_notificaciones_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table empresas
-- ----------------------------
ALTER TABLE "public"."empresas" ADD CONSTRAINT "fk_empresas_registro_usuario" FOREIGN KEY ("registro_usuario") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table integraciones_api
-- ----------------------------
ALTER TABLE "public"."integraciones_api" ADD CONSTRAINT "integraciones_api_empresa_id_fkey" FOREIGN KEY ("empresa_id") REFERENCES "public"."empresas" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."integraciones_api" ADD CONSTRAINT "integraciones_api_registro_usuario_fkey" FOREIGN KEY ("registro_usuario") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table inventario
-- ----------------------------
ALTER TABLE "public"."inventario" ADD CONSTRAINT "inventario_almacen_id_fkey" FOREIGN KEY ("almacen_id") REFERENCES "public"."almacenes" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."inventario" ADD CONSTRAINT "inventario_producto_id_fkey" FOREIGN KEY ("producto_id") REFERENCES "public"."productos" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."inventario" ADD CONSTRAINT "inventario_registro_usuario_fkey" FOREIGN KEY ("registro_usuario") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table log_actividad
-- ----------------------------
ALTER TABLE "public"."log_actividad" ADD CONSTRAINT "log_actividad_empresa_id_fkey" FOREIGN KEY ("empresa_id") REFERENCES "public"."empresas" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."log_actividad" ADD CONSTRAINT "log_actividad_registro_usuario_fkey" FOREIGN KEY ("registro_usuario") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."log_actividad" ADD CONSTRAINT "log_actividad_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table movimientos_inventario
-- ----------------------------
ALTER TABLE "public"."movimientos_inventario" ADD CONSTRAINT "movimientos_inventario_almacen_id_fkey" FOREIGN KEY ("almacen_id") REFERENCES "public"."almacenes" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."movimientos_inventario" ADD CONSTRAINT "movimientos_inventario_producto_id_fkey" FOREIGN KEY ("producto_id") REFERENCES "public"."productos" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."movimientos_inventario" ADD CONSTRAINT "movimientos_inventario_proveedor_id_fkey" FOREIGN KEY ("proveedor_id") REFERENCES "public"."proveedores" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."movimientos_inventario" ADD CONSTRAINT "movimientos_inventario_registro_usuario_fkey" FOREIGN KEY ("registro_usuario") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."movimientos_inventario" ADD CONSTRAINT "movimientos_inventario_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table productos
-- ----------------------------
ALTER TABLE "public"."productos" ADD CONSTRAINT "productos_categoria_id_fkey" FOREIGN KEY ("categoria_id") REFERENCES "public"."categorias" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."productos" ADD CONSTRAINT "productos_empresa_id_fkey" FOREIGN KEY ("empresa_id") REFERENCES "public"."empresas" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."productos" ADD CONSTRAINT "productos_proveedor_id_fkey" FOREIGN KEY ("proveedor_id") REFERENCES "public"."proveedores" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."productos" ADD CONSTRAINT "productos_registro_usuario_fkey" FOREIGN KEY ("registro_usuario") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table proveedores
-- ----------------------------
ALTER TABLE "public"."proveedores" ADD CONSTRAINT "proveedores_empresa_id_fkey" FOREIGN KEY ("empresa_id") REFERENCES "public"."empresas" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."proveedores" ADD CONSTRAINT "proveedores_registro_usuario_fkey" FOREIGN KEY ("registro_usuario") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table reportes
-- ----------------------------
ALTER TABLE "public"."reportes" ADD CONSTRAINT "reportes_empresa_id_fkey" FOREIGN KEY ("empresa_id") REFERENCES "public"."empresas" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."reportes" ADD CONSTRAINT "reportes_generado_por_id_fkey" FOREIGN KEY ("generado_por_id") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."reportes" ADD CONSTRAINT "reportes_registro_usuario_fkey" FOREIGN KEY ("registro_usuario") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table roles
-- ----------------------------
ALTER TABLE "public"."roles" ADD CONSTRAINT "fk_roles_registro_usuario" FOREIGN KEY ("registro_usuario") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table suscripciones
-- ----------------------------
ALTER TABLE "public"."suscripciones" ADD CONSTRAINT "suscripciones_empresa_id_fkey" FOREIGN KEY ("empresa_id") REFERENCES "public"."empresas" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."suscripciones" ADD CONSTRAINT "suscripciones_registro_usuario_fkey" FOREIGN KEY ("registro_usuario") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table usuarios
-- ----------------------------
ALTER TABLE "public"."usuarios" ADD CONSTRAINT "usuarios_empresa_id_fkey" FOREIGN KEY ("empresa_id") REFERENCES "public"."empresas" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."usuarios" ADD CONSTRAINT "usuarios_registro_usuario_fkey" FOREIGN KEY ("registro_usuario") REFERENCES "public"."usuarios" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "public"."usuarios" ADD CONSTRAINT "usuarios_rol_id_fkey" FOREIGN KEY ("rol_id") REFERENCES "public"."roles" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;
