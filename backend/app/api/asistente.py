from fastapi import APIRouter
from pydantic import BaseModel
from ..services.nlp_service import consultar_inventario
from ..services.db_service import execute_query
import json

router = APIRouter(prefix="/asistente", tags=["asistente"])

class QuestionRequest(BaseModel):
    pregunta: str

@router.post("/consultar/")
def consultar(req: QuestionRequest):
    productos = execute_query("SELECT id, nombre, stock_actual, unidad FROM producto", fetchall=True)
    if not productos:
        contexto = "El inventario está vacío."
    else:
        # Convertir DateTimes si los hubiera, pero RealDictCursor retorna dicts compatibles.
        # stock_actual puede ser Decimal, por lo que casteamos con str para JSON.
        lista = []
        for p in productos:
            lista.append({k: str(v) for k, v in p.items()})
        contexto = json.dumps(lista)
    
    respuesta = consultar_inventario(req.pregunta, contexto)
    return {"respuesta": respuesta}
