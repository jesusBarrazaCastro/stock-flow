import anthropic
import base64
import json
import os
from fastapi import HTTPException

# Asegúrate de proporcionar tu ANTHROPIC_API_KEY en el entorno
def leer_factura(imagen_bytes: bytes) -> dict:
    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key:
        print("Advertencia: No se encontró ANTHROPIC_API_KEY")
        # En desarrollo podemos evitar fallar y retornar un mock, o retornar error
        # Para el ejemplo retornamos un mock si falta el key
        return {
            "proveedor": "Mock Proveedor", 
            "fecha": "2024-01-01", 
            "productos": [
                {"nombre": "Mock Producto 1", "cantidad": 10, "unidad": "piezas"}
            ]
        }

    client = anthropic.Anthropic(api_key=api_key)
    imagen_b64 = base64.standard_b64encode(imagen_bytes).decode("utf-8")
    
    try:
        mensaje = client.messages.create(
            model="claude-3-opus-20240229", # Ajustado modelo válido
            max_tokens=1024,
            messages=[{
                "role": "user",
                "content": [
                    {
                        "type": "image",
                        "source": {
                            "type": "base64",
                            "media_type": "image/jpeg",
                            "data": imagen_b64
                        }
                    },
                    {
                        "type": "text",
                        "text": """Analiza esta factura o nota de compra. 
                        Extrae en formato JSON exacto: 
                        { "proveedor": "", "fecha": "", "productos": [{"nombre": "", "cantidad": 0, "unidad": ""}] }
                        Responde SOLO con el JSON válido, sin texto adicional."""
                    }
                ]
            }]
        )
        respuesta_texto = mensaje.content[0].text.strip()
        # Limpieza básica por si el modelo incluye marcas markdown
        if respuesta_texto.startswith("```json"):
            respuesta_texto = respuesta_texto[7:]
        if respuesta_texto.startswith("```"):
            respuesta_texto = respuesta_texto[3:]
        if respuesta_texto.endswith("```"):
            respuesta_texto = respuesta_texto[:-3]
            
        return json.loads(respuesta_texto)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error interpretando factura con IA: {str(e)}")
