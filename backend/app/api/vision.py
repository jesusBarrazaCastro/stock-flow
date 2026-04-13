from fastapi import APIRouter, UploadFile, File, HTTPException
from ..services.vision_service import leer_factura

router = APIRouter(prefix="/vision", tags=["vision"])

@router.post("/leer-factura/")
async def extraer_factura(file: UploadFile = File(...)):
    if not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="El archivo debe ser una imagen")
        
    image_bytes = await file.read()
    if len(image_bytes) == 0:
        raise HTTPException(status_code=400, detail="El archivo está vacío")
        
    resultado_json = leer_factura(image_bytes)
    return resultado_json
