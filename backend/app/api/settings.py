from fastapi import APIRouter, Depends, HTTPException

from ..services.db_service import execute_query
from ..core.security import get_current_user_token
from ..models.schemas import PerfilUpdate, EmpresaResponse, EmpresaUpdate, AlmacenesList

router = APIRouter(prefix="/settings", tags=["settings"])


def _call_sp(func_name: str, *args):
    placeholders = ", ".join(["%s"] * len(args))
    row = execute_query(
        f"SELECT {func_name}({placeholders}) AS result",
        args,
        fetchone=True,
    )
    return row["result"]


@router.put("/perfil")
def update_perfil(
    body: PerfilUpdate,
    token_payload: dict = Depends(get_current_user_token),
):
    email = token_payload.get("sub")
    data = _call_sp(
        "public.write_perfil",
        "update_profile",
        email,
        body.nombre_completo,
        body.telefono,
    )
    if "error" in data:
        raise HTTPException(status_code=400, detail=data["error"])
    return {"ok": True}


@router.get("/empresa", response_model=EmpresaResponse)
def get_empresa(token_payload: dict = Depends(get_current_user_token)):
    email = token_payload.get("sub")

    # Obtener empresa_id del usuario actual
    row = execute_query(
        "SELECT empresa_id FROM usuarios WHERE email = %s AND is_active = TRUE",
        (email,),
        fetchone=True,
    )
    if not row:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    empresa_id = row["empresa_id"]
    data = _call_sp("public.read_empresas", "get", empresa_id)

    if "error" in data:
        raise HTTPException(status_code=404, detail=data["error"])

    return EmpresaResponse(**data)


@router.put("/empresa")
def update_empresa(
    body: EmpresaUpdate,
    token_payload: dict = Depends(get_current_user_token),
):
    email = token_payload.get("sub")

    # Verificar que el usuario sea Admin
    row = execute_query(
        """
        SELECT u.empresa_id, r.nombre AS rol_nombre
        FROM usuarios u
        JOIN roles r ON r.id = u.rol_id
        WHERE u.email = %s AND u.is_active = TRUE
        """,
        (email,),
        fetchone=True,
    )
    if not row:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    if row["rol_nombre"] != "Admin":
        raise HTTPException(status_code=403, detail="Solo los administradores pueden editar la empresa")

    empresa_id = row["empresa_id"]
    data = _call_sp(
        "public.write_empresas",
        "update",
        empresa_id,
        body.razon_social,
        body.nombre_comercial,
        body.rfc,
        body.correo_electronico,
        body.telefono_principal,
        body.direccion_fiscal,
    )
    if "error" in data:
        raise HTTPException(status_code=400, detail=data["error"])
    return {"ok": True}


@router.get("/almacenes", response_model=AlmacenesList)
def get_almacenes(token_payload: dict = Depends(get_current_user_token)):
    """Retorna los almacenes activos de la empresa del usuario en sesión."""
    empresa_id = token_payload.get("empresa_id")
    if not empresa_id:
        raise HTTPException(status_code=400, detail="empresa_id no encontrado en token")
    data = _call_sp("public.read_almacenes", "list", empresa_id)
    if "error" in data:
        raise HTTPException(status_code=400, detail=data["error"])
    return data
