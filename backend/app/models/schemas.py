from pydantic import BaseModel
from typing import Optional, List, Literal
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
