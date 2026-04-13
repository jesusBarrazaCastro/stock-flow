from fastapi import APIRouter, HTTPException
from typing import List
from ..models.schemas import Movimiento, MovimientoCreate
from ..services.db_service import execute_query

router = APIRouter(prefix="/movimientos", tags=["movimientos"])

@router.post("/", response_model=Movimiento)
def registrar_movimiento(mov: MovimientoCreate):
    # Insertar el movimiento y actualizar el stock del producto
    query = """
    INSERT INTO movimiento (producto_id, tipo, cantidad, proveedor, nota, imagen_url, origen)
    VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING id, created_at;
    """
    params = (mov.producto_id, mov.tipo, mov.cantidad, mov.proveedor, mov.nota, mov.imagen_url, mov.origen)
    try:
        nuevo = execute_query(query, params, fetchone=True, commit=True)
        # Actualizar stock
        op = "+" if mov.tipo == "entrada" else "-"
        query_stock = f"UPDATE producto SET stock_actual = stock_actual {op} %s WHERE id = %s"
        execute_query(query_stock, (mov.cantidad, mov.producto_id), commit=True)
        
        return Movimiento(**mov.dict(), id=nuevo['id'], created_at=nuevo['created_at'])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
