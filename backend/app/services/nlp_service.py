import anthropic
import os
from fastapi import HTTPException

def consultar_inventario(pregunta: str, contexto_inventario: str) -> str:
    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key:
        print("Advertencia: No se encontró ANTHROPIC_API_KEY en NLP_service")
        return "No tengo configurada mi clave de API para responder preguntas reales. (Modo MOCK)"

    client = anthropic.Anthropic(api_key=api_key)
    
    try:
        mensaje = client.messages.create(
            model="claude-3-haiku-20240307", # Haiku es rápido e ideal para el asistente
            max_tokens=512,
            system=f"""Eres el asistente inteligente de inventario de 'Stock Flow'. 
            Tienes acceso al siguiente estado actual del inventario:
            {contexto_inventario}
            Responde las preguntas del usuario de forma concisa, directa y amigable en español. 
            Si te preguntan por algo que no está en el inventario, indícalo claramente.""",
            messages=[{"role": "user", "content": pregunta}]
        )
        return mensaje.content[0].text
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error consultando asistente: {str(e)}")
