from fastapi import APIRouter, HTTPException
from typing import List
from ..models.schemas import Producto, ProductoCreate
from ..services.db_service import execute_query

router = APIRouter(prefix="/productos", tags=["productos"])

@router.get("/", response_model=List[Producto])
def get_productos():
    query = "SELECT id, usuario_id, nombre, sku, unidad, stock_actual, stock_minimo, created_at FROM producto"
    productos = execute_query(query, fetchall=True)
    if productos is None:
        return []
    return [Producto(**p) for p in productos]

@router.post("/", response_model=Producto)
def crear_producto(producto: ProductoCreate):
    query = """
    INSERT INTO producto (usuario_id, nombre, sku, unidad, stock_actual, stock_minimo)
    VALUES (%s, %s, %s, %s, %s, %s) RETURNING id, created_at;
    """
    params = (producto.usuario_id, producto.nombre, producto.sku, producto.unidad, producto.stock_actual, producto.stock_minimo)
    try:
        nuevo = execute_query(query, params, fetchone=True, commit=True)
        return Producto(**producto.dict(), id=nuevo['id'], created_at=nuevo['created_at'])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
