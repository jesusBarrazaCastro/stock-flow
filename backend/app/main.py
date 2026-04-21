from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .api import productos, movimientos, vision, asistente, auth, settings, proveedores

app = FastAPI(title="Stock Flow Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api")
app.include_router(productos.router, prefix="/api")
app.include_router(movimientos.router, prefix="/api")
app.include_router(vision.router, prefix="/api")
app.include_router(asistente.router, prefix="/api")
app.include_router(settings.router, prefix="/api")
app.include_router(proveedores.router, prefix="/api")

@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.get("/")
def read_root():
    return {"message": "Stock Flow Backend is running"}
