from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional

from ..services.db_service import execute_query
from ..core.security import get_current_user_token
from ..models.schemas import (
    CatalogoPaginado,
    ProductoDetalle,
    ProductoUpdate,
    ProductoCatalogCreate,
    CategoriasList,
)

router = APIRouter(prefix="/productos", tags=["productos"])


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


@router.post("/")
def create_producto(
    body: ProductoCatalogCreate,
    token_payload: dict = Depends(get_current_user_token),
):
    empresa_id = _get_empresa_id(token_payload)
    usuario_id = token_payload.get("id")
    data = _call_sp(
        "public.write_productos",
        "register",
        empresa_id,
        None,
        body.nombre,
        body.sku,
        body.descripcion,
        body.precio_unitario,
        body.categoria_id,
        None,
        body.unidad_medida,
        body.stock_minimo,
        body.stock_maximo,
        body.imagen_url,
        None,
        body.ubicacion_fisica,
        None,
        usuario_id,
    )
    if "error" in data:
        raise HTTPException(status_code=400, detail=data["error"])
    return data


@router.get("/categorias", response_model=CategoriasList)
def get_categorias(token_payload: dict = Depends(get_current_user_token)):
    empresa_id = _get_empresa_id(token_payload)
    data = _call_sp("public.read_productos", "categories", empresa_id)
    if "error" in data:
        raise HTTPException(status_code=400, detail=data["error"])
    return data


@router.get("/catalogo", response_model=CatalogoPaginado)
def get_catalogo(
    search: Optional[str] = Query(None),
    categoria_id: Optional[int] = Query(None),
    sort: str = Query("newest"),
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=50),
    token_payload: dict = Depends(get_current_user_token),
):
    empresa_id = _get_empresa_id(token_payload)
    data = _call_sp(
        "public.read_productos",
        "list",
        empresa_id,
        None,
        search,
        categoria_id,
        sort,
        page,
        limit,
    )
    if "error" in data:
        raise HTTPException(status_code=400, detail=data["error"])
    return data


@router.get("/{producto_id}/detalle", response_model=ProductoDetalle)
def get_producto_detalle(
    producto_id: int,
    token_payload: dict = Depends(get_current_user_token),
):
    empresa_id = _get_empresa_id(token_payload)
    data = _call_sp("public.read_productos", "detail", empresa_id, producto_id)
    if "error" in data:
        raise HTTPException(status_code=404, detail=data["error"])
    return data


@router.put("/{producto_id}")
def update_producto(
    producto_id: int,
    body: ProductoUpdate,
    token_payload: dict = Depends(get_current_user_token),
):
    empresa_id = _get_empresa_id(token_payload)
    usuario_id = token_payload.get("id")
    data = _call_sp(
        "public.write_productos",
        "update",
        empresa_id,
        producto_id,
        body.nombre,
        body.sku,
        body.descripcion,
        body.precio_unitario,
        body.categoria_id,
        body.proveedor_id,
        body.unidad_medida,
        body.stock_minimo,
        body.stock_maximo,
        body.imagen_url,
        body.almacen_id,
        body.ubicacion_fisica,
        body.cantidad_nueva,
        usuario_id,
    )
    if "error" in data:
        raise HTTPException(status_code=400, detail=data["error"])
    return data
