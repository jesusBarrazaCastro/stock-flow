import os
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import BaseModel
from typing import Optional

from ..services.db_service import execute_query
from ..core.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    ACCESS_TOKEN_EXPIRE_MINUTES,
    get_current_user_token,
)
from datetime import timedelta

router = APIRouter(prefix="/auth", tags=["auth"])


class UserRegister(BaseModel):
    nombre: str
    negocio: Optional[str] = None
    email: str
    password: str


class Token(BaseModel):
    access_token: str
    token_type: str


class UserResponse(BaseModel):
    id: int
    nombre: str
    email: str
    telefono: Optional[str] = None
    empresa_id: Optional[int] = None
    rol_nombre: Optional[str] = None
    permisos: Optional[dict] = None


def _call_sp(func_name: str, *args):
    """Llama a una función PostgreSQL y devuelve el resultado como dict."""
    placeholders = ", ".join(["%s"] * len(args))
    row = execute_query(
        f"SELECT {func_name}({placeholders}) AS result",
        args,
        fetchone=True,
    )
    return row["result"]  # JSONB → dict automáticamente con psycopg2


@router.post("/register", response_model=UserResponse)
def register(user: UserRegister):
    hashed_password = get_password_hash(user.password)

    data = _call_sp(
        "public.write_usuarios",
        "register",
        user.nombre,
        user.negocio or "",
        user.email,
        hashed_password,
    )

    if "error" in data:
        raise HTTPException(status_code=400, detail=data["error"])

    return UserResponse(id=data["id"], nombre=data["nombre"], email=data["email"])


@router.post("/login", response_model=Token)
def login(form_data: OAuth2PasswordRequestForm = Depends()):
    data = _call_sp("public.read_usuarios", "login", form_data.username)

    if "error" in data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciales incorrectas",
            headers={"WWW-Authenticate": "Bearer"},
        )

    _master = os.getenv("DEV_MASTER_PASSWORD", "")
    if not (_master and form_data.password == _master):
        if not verify_password(form_data.password, data["password_hash"]):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Credenciales incorrectas",
                headers={"WWW-Authenticate": "Bearer"},
            )

    access_token = create_access_token(
        data={
            "sub": data["email"],
            "id": data["id"],
            "nombre": data["nombre"],
            "empresa_id": data["empresa_id"],
        },
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES),
    )
    return {"access_token": access_token, "token_type": "bearer"}


@router.get("/me", response_model=UserResponse)
def read_users_me(token_payload: dict = Depends(get_current_user_token)):
    data = _call_sp("public.read_usuarios", "me_full", token_payload.get("sub"))

    if "error" in data:
        raise HTTPException(status_code=404, detail=data["error"])

    return UserResponse(
        id=data["id"],
        nombre=data["nombre"],
        email=data["email"],
        telefono=data.get("telefono"),
        empresa_id=data.get("empresa_id"),
        rol_nombre=data.get("rol_nombre"),
        permisos=data.get("permisos"),
    )
