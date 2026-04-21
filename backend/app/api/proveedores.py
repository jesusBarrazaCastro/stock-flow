from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional

from ..services.db_service import execute_query
from ..core.security import get_current_user_token
from ..models.schemas import (
    ProveedorLista,
    ProveedorDetalle,
    ProveedorCreate,
    ProveedorUpdate,
)

router = APIRouter(prefix="/proveedores", tags=["proveedores"])


def _call_sp(func_name: str, *args):
    placeholders = ", ".join(["%s"] * len(args))
    row = execute_query(
        f"SELECT {func_name}({placeholders}) AS result",
        args,
        fetchone=True,
    )
    return row["result"]


def _get_empresa_id(token_payload: dict) -> int:
    empresa_id = token_payload.get("empresa_id")
    if not empresa_id:
        raise HTTPException(status_code=400, detail="empresa_id no encontrado en token")
    return empresa_id


@router.get("/lista", response_model=ProveedorLista)
def get_proveedores(
    search: Optional[str] = Query(None),
    categoria: Optional[str] = Query(None),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    estado: Optional[str] = Query(None),
    max_dias: Optional[int] = Query(None, ge=1),
    token_payload: dict = Depends(get_current_user_token),
):
    empresa_id = _get_empresa_id(token_payload)
    data = _call_sp(
        "public.read_proveedores",
        "list",
        empresa_id,
        None,
        search,
        categoria,
        page,
        limit,
        estado,
        max_dias,
    )
    if "error" in data:
        raise HTTPException(status_code=400, detail=data["error"])
    return data


@router.get("/{proveedor_id}/detalle", response_model=ProveedorDetalle)
def get_proveedor_detalle(
    proveedor_id: int,
    token_payload: dict = Depends(get_current_user_token),
):
    empresa_id = _get_empresa_id(token_payload)
    data = _call_sp("public.read_proveedores", "detail", empresa_id, proveedor_id)
    if "error" in data:
        raise HTTPException(status_code=404, detail=data["error"])
    return data


@router.post("/")
def create_proveedor(
    body: ProveedorCreate,
    token_payload: dict = Depends(get_current_user_token),
):
    empresa_id = _get_empresa_id(token_payload)
    usuario_id = token_payload.get("id")
    data = _call_sp(
        "public.write_proveedores",
        "register",
        empresa_id,
        None,
        body.nombre,
        body.categoria,
        body.contacto_nombre,
        body.contacto_email,
        body.contacto_telefono,
        body.direccion,
        body.dias_entrega,
        body.logo_url,
        body.calificacion,
        body.certificado_desde,
        body.notas,
        usuario_id,
    )
    if "error" in data:
        raise HTTPException(status_code=400, detail=data["error"])
    return data


@router.put("/{proveedor_id}")
def update_proveedor(
    proveedor_id: int,
    body: ProveedorUpdate,
    token_payload: dict = Depends(get_current_user_token),
):
    empresa_id = _get_empresa_id(token_payload)
    usuario_id = token_payload.get("id")
    data = _call_sp(
        "public.write_proveedores",
        "update",
        empresa_id,
        proveedor_id,
        body.nombre,
        body.categoria,
        body.contacto_nombre,
        body.contacto_email,
        body.contacto_telefono,
        body.direccion,
        body.dias_entrega,
        body.logo_url,
        body.calificacion,
        body.certificado_desde,
        body.notas,
        usuario_id,
    )
    if "error" in data:
        raise HTTPException(status_code=400, detail=data["error"])
    return data
