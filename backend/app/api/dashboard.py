from fastapi import APIRouter, Depends, HTTPException, Query

from ..services.db_service import execute_query
from ..core.security import get_current_user_token
from ..models.schemas import (
    DashboardKpisResponse,
    DashboardActividadResponse,
    InsightsResponse,
)

router = APIRouter(prefix="/dashboard", tags=["dashboard"])


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


@router.get("/kpis", response_model=DashboardKpisResponse)
def get_kpis(
    token_payload: dict = Depends(get_current_user_token),
):
    empresa_id = _get_empresa_id(token_payload)
    data = _call_sp("public.read_dashboard", "kpis", empresa_id)

    if isinstance(data, dict) and "error" in data:
        raise HTTPException(status_code=400, detail=data["error"])

    return DashboardKpisResponse(**data)


@router.get("/actividad", response_model=DashboardActividadResponse)
def get_actividad(
    limit: int = Query(default=5, ge=1, le=20),
    token_payload: dict = Depends(get_current_user_token),
):
    empresa_id = _get_empresa_id(token_payload)
    data = _call_sp("public.read_dashboard", "actividad", empresa_id, limit)

    if isinstance(data, dict) and "error" in data:
        raise HTTPException(status_code=400, detail=data["error"])

    return DashboardActividadResponse(**data)


@router.get("/insights", response_model=InsightsResponse)
def get_insights(
    token_payload: dict = Depends(get_current_user_token),
):
    empresa_id = _get_empresa_id(token_payload)
    data = _call_sp("public.read_dashboard", "insights", empresa_id)

    if isinstance(data, dict) and "error" in data:
        raise HTTPException(status_code=400, detail=data["error"])

    return InsightsResponse(**data)
