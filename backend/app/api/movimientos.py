from fastapi import APIRouter, Depends, HTTPException
from typing import Optional

from ..services.db_service import execute_query
from ..core.security import get_current_user_token
from ..models.schemas import MovimientoRegistrar, MovimientoResponse, CaducidadUpdate

router = APIRouter(prefix="/movimientos", tags=["movimientos"])


def _call_sp(func_name: str, *args):
    placeholders = ", ".join(["%s"] * len(args))
    row = execute_query(
        f"SELECT {func_name}({placeholders}) AS result",
        args,
        fetchone=True,
    )
    return row["result"]


def _get_empresa_usuario(token_payload: dict):
    empresa_id = token_payload.get("empresa_id")
    usuario_id = token_payload.get("id")
    if not empresa_id:
        raise HTTPException(status_code=400, detail="empresa_id no encontrado en token")
    if not usuario_id:
        raise HTTPException(status_code=400, detail="usuario_id no encontrado en token")
    return empresa_id, usuario_id


@router.post("/registrar", response_model=MovimientoResponse)
def registrar_movimiento(
    body: MovimientoRegistrar,
    token_payload: dict = Depends(get_current_user_token),
):
    """
    Registra un movimiento de inventario (ENTRADA o SALIDA) de forma manual.
    Valida permisos por empresa, stock suficiente en SALIDA, y actualiza inventario
    dentro de una única transacción en la SP write_movimientos.
    """
    empresa_id, usuario_id = _get_empresa_usuario(token_payload)

    data = _call_sp(
        "public.write_movimientos",
        "register",
        empresa_id,
        body.producto_id,
        body.almacen_id,
        usuario_id,
        body.tipo,
        body.cantidad,
        body.precio_unitario,
        body.proveedor_id,
        body.notas,
        body.fecha,
        body.fecha_caducidad,
        body.lote_entrada_id,
    )

    if "error" in data:
        raise HTTPException(status_code=400, detail=data["error"])

    return MovimientoResponse(**data)


@router.patch("/{movimiento_id}/caducidad")
def actualizar_caducidad(
    movimiento_id: int,
    body: CaducidadUpdate,
    token_payload: dict = Depends(get_current_user_token),
):
    empresa_id, _ = _get_empresa_usuario(token_payload)
    data = _call_sp(
        "public.write_lotes",
        "update_caducidad",
        empresa_id,
        movimiento_id,
        body.nueva_fecha,
    )
    if "error" in data:
        raise HTTPException(status_code=400, detail=data["error"])
    return data
