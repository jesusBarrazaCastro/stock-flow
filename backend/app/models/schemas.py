from pydantic import BaseModel
from typing import Optional, List, Literal, Any
from datetime import datetime

class UsuarioBase(BaseModel):
    nombre: str
    email: str
    negocio: Optional[str] = None

class UsuarioCreate(UsuarioBase):
    pass

class Usuario(UsuarioBase):
    id: int
    created_at: Optional[datetime] = None

class ProductoBase(BaseModel):
    nombre: str
    sku: Optional[str] = None
    unidad: Optional[str] = None
    stock_actual: float = 0.0
    stock_minimo: float = 0.0

class ProductoCreate(ProductoBase):
    usuario_id: int

class Producto(ProductoBase):
    id: int
    usuario_id: int
    created_at: Optional[datetime] = None

class PerfilUpdate(BaseModel):
    nombre_completo: str
    telefono: Optional[str] = None

class EmpresaResponse(BaseModel):
    id: int
    razon_social: str
    nombre_comercial: Optional[str] = None
    rfc: Optional[str] = None
    correo_electronico: Optional[str] = None
    telefono_principal: Optional[str] = None
    direccion_fiscal: Optional[str] = None
    plan_suscripcion: str
    limite_almacenes: Optional[int] = None
    fecha_registro: Optional[str] = None

class EmpresaUpdate(BaseModel):
    razon_social: str
    nombre_comercial: Optional[str] = None
    rfc: Optional[str] = None
    correo_electronico: Optional[str] = None
    telefono_principal: Optional[str] = None
    direccion_fiscal: Optional[str] = None

class MovimientoBase(BaseModel):
    tipo: Literal['entrada', 'salida']
    cantidad: float
    proveedor: Optional[str] = None
    nota: Optional[str] = None
    imagen_url: Optional[str] = None
    origen: Literal['foto', 'voz', 'manual'] = 'manual'

class MovimientoCreate(MovimientoBase):
    producto_id: int

class Movimiento(MovimientoBase):
    id: int
    producto_id: int
    created_at: Optional[datetime] = None


# ── Catálogo schemas ──────────────────────────────────────────────────────

class MovimientoReciente(BaseModel):
    id: int
    tipo_movimiento: str
    cantidad: int
    precio_unitario: Optional[float] = None
    fecha_movimiento: Optional[str] = None
    notas: Optional[str] = None
    metodo_registro: str = 'MANUAL'
    almacen_nombre: Optional[str] = None
    usuario_nombre: Optional[str] = None

class CatalogoProductoItem(BaseModel):
    id: int
    nombre: str
    sku: str
    descripcion: Optional[str] = None
    precio_unitario: float = 0.0
    imagen_url: Optional[str] = None
    unidad_medida: str = 'unidad'
    stock_minimo: int = 0
    stock_maximo: Optional[int] = None
    registro_fecha: Optional[Any] = None
    categoria_id: Optional[int] = None
    categoria_nombre: Optional[str] = None
    categoria_color: Optional[str] = None
    proveedor_id: Optional[int] = None
    proveedor_nombre: Optional[str] = None
    stock_total: int = 0
    estado_stock: str = 'AGOTADO'

class CatalogoPaginado(BaseModel):
    items: List[CatalogoProductoItem]
    total: int
    page: int
    limit: int
    pages: float

class ProductoDetalle(CatalogoProductoItem):
    ubicacion_fisica: Optional[str] = None
    almacen_id: Optional[int] = None
    almacen_nombre: Optional[str] = None
    movimientos_recientes: List[MovimientoReciente] = []

class ProductoUpdate(BaseModel):
    nombre: Optional[str] = None
    sku: Optional[str] = None
    descripcion: Optional[str] = None
    precio_unitario: Optional[float] = None
    categoria_id: Optional[int] = None
    proveedor_id: Optional[int] = None
    unidad_medida: Optional[str] = None
    stock_minimo: Optional[int] = None
    stock_maximo: Optional[int] = None
    imagen_url: Optional[str] = None
    almacen_id: Optional[int] = None
    ubicacion_fisica: Optional[str] = None
    cantidad_nueva: Optional[int] = None

class CategoriaItem(BaseModel):
    id: int
    nombre: str
    color_hex: Optional[str] = None

class CategoriasList(BaseModel):
    items: List[CategoriaItem]

class ProductoCatalogCreate(BaseModel):
    nombre: str
    sku: str
    descripcion: Optional[str] = None
    precio_unitario: float = 0.0
    categoria_id: Optional[int] = None
    unidad_medida: str = 'unidad'
    stock_minimo: int = 0
    stock_maximo: Optional[int] = None
    imagen_url: Optional[str] = None
    ubicacion_fisica: Optional[str] = None


# ── Proveedor schemas ─────────────────────────────────────────────────────

class ProductoSuministrado(BaseModel):
    id: int
    nombre: str
    sku: str
    imagen_url: Optional[str] = None
    categoria_nombre: Optional[str] = None
    categoria_color: Optional[str] = None
    stock_total: int = 0


class PedidoHistorial(BaseModel):
    id: int
    numero_pedido: str
    fecha: Optional[str] = None
    cantidad: int
    precio_unitario: Optional[float] = None
    monto_total: float = 0.0
    producto_nombre: Optional[str] = None
    estado_pedido: str = 'COMPLETADO'


class ProveedorListItem(BaseModel):
    id: int
    nombre: str
    categoria: Optional[str] = None
    contacto_nombre: Optional[str] = None
    contacto_email: Optional[str] = None
    contacto_telefono: Optional[str] = None
    direccion: Optional[str] = None
    dias_entrega: Optional[int] = 5
    logo_url: Optional[str] = None
    calificacion: Optional[float] = 0.0
    certificado_desde: Optional[int] = None
    notas: Optional[str] = None
    registro_fecha: Optional[str] = None
    estado: str = 'ACTIVO'
    total_productos: int = 0


class ProveedorLista(BaseModel):
    items: List[ProveedorListItem]
    total: int
    page: int
    limit: int
    pages: float
    aliados_total: int = 0
    nuevos: int = 0
    en_revision: int = 0


class ProveedorDetalle(ProveedorListItem):
    productos_suministrados: List[ProductoSuministrado] = []
    pedidos_total: int = 0
    cumplimiento: float = 0.0
    tiempo_entrega: float = 0.0
    historial_pedidos: List[PedidoHistorial] = []


class ProveedorCreate(BaseModel):
    nombre: str
    categoria: Optional[str] = None
    contacto_nombre: Optional[str] = None
    contacto_email: Optional[str] = None
    contacto_telefono: Optional[str] = None
    direccion: Optional[str] = None
    dias_entrega: int = 5
    logo_url: Optional[str] = None
    calificacion: Optional[float] = None
    certificado_desde: Optional[int] = None
    notas: Optional[str] = None


class ProveedorUpdate(BaseModel):
    nombre: Optional[str] = None
    categoria: Optional[str] = None
    contacto_nombre: Optional[str] = None
    contacto_email: Optional[str] = None
    contacto_telefono: Optional[str] = None
    direccion: Optional[str] = None
    dias_entrega: Optional[int] = None
    logo_url: Optional[str] = None
    calificacion: Optional[float] = None
    certificado_desde: Optional[int] = None
    notas: Optional[str] = None


# ── Movimiento schemas ───────────────────────────────────────────────────────

class MovimientoRegistrar(BaseModel):
    producto_id: int
    almacen_id: Optional[int] = None
    tipo: Literal['ENTRADA', 'SALIDA']
    cantidad: int
    precio_unitario: Optional[float] = None
    proveedor_id: Optional[int] = None
    notas: Optional[str] = None
    fecha: Optional[datetime] = None


class MovimientoResponse(BaseModel):
    ok: bool
    movimiento_id: int
    stock_nuevo: int


class AlmacenItem(BaseModel):
    id: int
    nombre: str
    direccion: Optional[str] = None
    capacidad_maxima: Optional[int] = None
    is_active: bool = True


class AlmacenesList(BaseModel):
    items: List[AlmacenItem]


# ── Dashboard schemas ────────────────────────────────────────────────────────

class DashboardKpisResponse(BaseModel):
    inventario_total_unidades: int = 0
    total_productos: int = 0
    total_almacenes: int = 0
    capacidad_total: int = 0


class DashboardActividadItem(BaseModel):
    id: int
    tipo_movimiento: str
    cantidad: int
    fecha_movimiento: str
    producto_nombre: Optional[str] = None
    almacen_nombre: Optional[str] = None


class DashboardActividadResponse(BaseModel):
    items: List[DashboardActividadItem]


class InsightsDia(BaseModel):
    fecha: str
    total: int = 0


class InsightsResponse(BaseModel):
    sin_datos: bool = False
    producto_nombre: Optional[str] = None
    pct_cambio: Optional[float] = None
    dias: List[InsightsDia] = []
