# 🔄 Guía de Transición: De Detección de Placas → Stock Flow

> **Destinatario:** Google Antigravity  
> **Propósito:** Usar el proyecto `deteccion-placas` como base de código para arrancar el desarrollo de **Stock Flow: Gestión de Inventarios Ágil con IA**  
> **Autores originales del proyecto base:** Jesús Alberto Barraza Castro & Jesús Guadalupe Wong Camacho — TecNM Campus Culiacán

---

## 🧭 Contexto General

Ambos proyectos comparten el **mismo stack tecnológico** (Flutter + FastAPI + PostgreSQL + Docker), lo que hace que el repositorio de detección de placas sea una base sólida para arrancar Stock Flow sin empezar desde cero.

| Capa | Detección de Placas | Stock Flow |
|:---|:---|:---|
| **Frontend** | Flutter (móvil/web) | Flutter (móvil — iOS & Android) |
| **Backend** | Python + FastAPI | Python + FastAPI |
| **Base de Datos** | PostgreSQL | PostgreSQL |
| **Despliegue** | Docker & Docker Compose | Docker & Docker Compose |
| **IA** | Visión por Computadora (OCR de placas) | Visión (lectura de facturas) + NLP (asistente de voz) |

La diferencia principal está en la **lógica de negocio** y los **modelos de IA**: en lugar de detectar placas, Stock Flow interpreta facturas y responde consultas en lenguaje natural sobre inventario.

---

## 📁 Estructura del Repositorio Base y Qué Reutilizar

```
📦 deteccion-placas  →  📦 stock-flow
├── docker-compose.yml        ✅ REUTILIZAR — ajustar nombres de servicios
├── backend/                  ✅ REUTILIZAR ESTRUCTURA — reemplazar lógica de CV
│   ├── main.py               ✅ Punto de entrada FastAPI — mantener patrón
│   ├── api/                  ✅ Routers — reemplazar endpoints
│   ├── models/               ✅ Modelos Pydantic — reescribir para inventario
│   └── services/             🔁 REEMPLAZAR — quitar OCR de placas, agregar:
│       ├── vision_service.py     → lector de facturas (Claude Vision / GPT-4V)
│       └── nlp_service.py        → asistente NLP (nuevo archivo)
├── frontend/                 ✅ REUTILIZAR ESTRUCTURA — reemplazar pantallas
│   ├── lib/
│   │   ├── services/
│   │   │   └── api_service.dart  ✅ Reutilizar patrón de llamadas HTTP
│   │   ├── screens/          🔁 REEMPLAZAR — nuevas pantallas de Stock Flow
│   │   └── widgets/          🔁 REEMPLAZAR — nuevos componentes UI
├── database_scripts/         🔁 REEMPLAZAR — nuevo esquema de inventario
└── docs/                     📝 ACTUALIZAR con documentación de Stock Flow
```

**Leyenda:**  
✅ Reutilizar sin cambios mayores | 🔁 Reemplazar contenido, mantener patrón | 📝 Actualizar

---

## 🗄️ Paso 1 — Migrar la Base de Datos

### Qué eliminar del esquema actual
Las tablas `vehiculo`, `scan_log` e `incidencia` del proyecto de placas **no aplican** para Stock Flow. Conservar únicamente la tabla `persona` como referencia para el modelo de `usuario`.

### Nuevo esquema para Stock Flow

Crear los siguientes scripts SQL en `database_scripts/`:

```sql
-- Tabla de usuarios (evolución de 'persona')
CREATE TABLE usuario (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    email       VARCHAR(150) UNIQUE NOT NULL,
    negocio     VARCHAR(150),
    created_at  TIMESTAMP DEFAULT NOW()
);

-- Catálogo de productos
CREATE TABLE producto (
    id              SERIAL PRIMARY KEY,
    usuario_id      INT REFERENCES usuario(id),
    nombre          VARCHAR(200) NOT NULL,
    sku             VARCHAR(100),
    unidad          VARCHAR(50),   -- piezas, kg, litros, etc.
    stock_actual    NUMERIC(10,2) DEFAULT 0,
    stock_minimo    NUMERIC(10,2) DEFAULT 0,
    created_at      TIMESTAMP DEFAULT NOW()
);

-- Movimientos de inventario (entradas y salidas)
CREATE TABLE movimiento (
    id              SERIAL PRIMARY KEY,
    producto_id     INT REFERENCES producto(id),
    tipo            VARCHAR(10) CHECK (tipo IN ('entrada', 'salida')),
    cantidad        NUMERIC(10,2) NOT NULL,
    proveedor       VARCHAR(200),
    nota            TEXT,
    imagen_url      TEXT,           -- URL de la factura capturada
    origen          VARCHAR(20) CHECK (origen IN ('foto', 'voz', 'manual')),
    created_at      TIMESTAMP DEFAULT NOW()
);
```

> **Nota:** El procedimiento almacenado `read_vehiculos` con su lógica de búsqueda inteligente es un buen patrón a replicar para la búsqueda de productos con coincidencia parcial/fuzzy.

---

## ⚙️ Paso 2 — Adaptar el Backend (FastAPI)

### 2.1 Mantener la estructura de routers

El patrón de routers del proyecto de placas es directo y limpio. Replicarlo así:

```
backend/
└── api/
    ├── usuarios.py       # Login, registro
    ├── productos.py      # CRUD de productos
    ├── movimientos.py    # Registrar entradas/salidas
    ├── vision.py         # 🆕 Recibir foto de factura → extraer datos con IA
    └── asistente.py      # 🆕 Recibir consulta en texto → responder sobre inventario
```

### 2.2 Reemplazar el endpoint de detección

El endpoint original de placas:
```
POST /api/vehiculos/detect-plate/   →   recibe imagen, corre modelo CV
```

Se convierte en dos endpoints nuevos para Stock Flow:

```
POST /api/vision/leer-factura/      →   recibe imagen de factura, extrae productos/cantidades
POST /api/asistente/consultar/      →   recibe texto en lenguaje natural, responde sobre stock
```

### 2.3 Nuevo servicio de Visión (reemplaza el OCR de placas)

En lugar del modelo de CV para placas, integrar un modelo multimodal (Claude Vision o GPT-4V) para interpretar facturas:

```python
# backend/services/vision_service.py

import anthropic
import base64

def leer_factura(imagen_bytes: bytes) -> dict:
    client = anthropic.Anthropic()
    imagen_b64 = base64.standard_b64encode(imagen_bytes).decode("utf-8")
    
    mensaje = client.messages.create(
        model="claude-opus-4-5",
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
                    Extrae en formato JSON: 
                    { "proveedor": "", "fecha": "", "productos": [{"nombre": "", "cantidad": 0, "unidad": ""}] }
                    Responde SOLO el JSON, sin texto adicional."""
                }
            ]
        }]
    )
    import json
    return json.loads(mensaje.content[0].text)
```

### 2.4 Nuevo servicio de Asistente NLP

```python
# backend/services/nlp_service.py

import anthropic

def consultar_inventario(pregunta: str, contexto_inventario: str) -> str:
    client = anthropic.Anthropic()
    
    mensaje = client.messages.create(
        model="claude-opus-4-5",
        max_tokens=512,
        system=f"""Eres el asistente de inventario de Stock Flow. 
        Tienes acceso al siguiente inventario actual:
        {contexto_inventario}
        Responde de forma concisa y directa en español.""",
        messages=[{"role": "user", "content": pregunta}]
    )
    return mensaje.content[0].text
```

---

## 📱 Paso 3 — Adaptar el Frontend (Flutter)

### 3.1 Qué conservar de `api_service.dart`

El patrón de llamadas HTTP del proyecto de placas es reutilizable al 100%. Mantener la clase base y agregar los nuevos métodos:

```dart
// lib/services/api_service.dart

// ✅ CONSERVAR: configuración base de http, manejo de errores, baseUrl

// 🆕 AGREGAR estos métodos nuevos:

Future<Map<String, dynamic>> leerFactura(File imagen) async { ... }
Future<String> consultarAsistente(String pregunta) async { ... }
Future<List<Producto>> obtenerProductos() async { ... }
Future<void> registrarMovimiento(Movimiento movimiento) async { ... }
```

### 3.2 Pantallas a crear (reemplazar las de placas)

Eliminar todas las pantallas actuales relacionadas con escaneo de placas e incidencias. Crear las siguientes en `lib/screens/`:

| Pantalla | Archivo | Basarse en |
|:---|:---|:---|
| Onboarding / Login | `onboarding_screen.dart` | Nueva |
| Dashboard principal | `dashboard_screen.dart` | Pantalla de inicio de placas (estructura general) |
| Captura de factura | `captura_factura_screen.dart` | **`scan_screen.dart`** — misma lógica de cámara |
| Nota de voz | `nota_voz_screen.dart` | Nueva |
| Confirmación de datos | `confirmacion_screen.dart` | Pantalla de resultado de placas (estructura de tarjeta) |
| Asistente IA (chat) | `asistente_screen.dart` | Nueva |
| Reportes | `reportes_screen.dart` | Nueva |
| Historial | `historial_screen.dart` | Pantalla de logs de placas (`logs_screen.dart`) |

> **Clave:** La pantalla de escaneo de cámara y la pantalla de historial/logs son las más aprovechables del proyecto base. Reutilizar su lógica de captura y listado, solo cambiar la UI y los datos que muestran.

### 3.3 Estilo visual

El proyecto de placas tiene un estilo propio. Stock Flow usa una paleta diferente. Centralizar el tema en:

```dart
// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  static const coral     = Color(0xFFE8836A);
  static const coralSuave = Color(0xFFF2A98B);
  static const fondoCalido = Color(0xFFFAF0EC);
  static const textoDark  = Color(0xFF2D2D2D);
  static const textoGris  = Color(0xFF8A8A8A);

  static ThemeData get tema => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: coral),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Lora',       // serif para títulos
    // body font: 'DM Sans'
  );
}
```

---

## 🐳 Paso 4 — Actualizar Docker Compose

Cambiar nombres de servicios en `docker-compose.yml` para reflejar Stock Flow. El patrón de contenedores es idéntico:

```yaml
# docker-compose.yml

services:
  stockflow-backend:       # antes: placas-backend
    build: ./backend
    ports:
      - "8000:8000"
    depends_on:
      - stockflow-db
    environment:
      - DATABASE_URL=postgresql://user:pass@stockflow-db:5432/stockflow_db

  stockflow-db:            # antes: placas-db
    image: postgres:15
    environment:
      POSTGRES_DB: stockflow_db
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - ./data:/var/lib/postgresql/data
      - ./database_scripts:/docker-entrypoint-initdb.d
```

---

## ✅ Checklist de Arranque

Seguir este orden para no bloquearse:

- [ ] Clonar el repo `deteccion-placas` y renombrarlo a `stock-flow`
- [ ] Reemplazar `database_scripts/` con el nuevo esquema SQL
- [ ] Levantar DB con `docker-compose up -d` y verificar que las tablas existen
- [ ] Crear los nuevos routers en `backend/api/` (productos, movimientos, vision, asistente)
- [ ] Implementar `vision_service.py` con integración al modelo de IA
- [ ] Implementar `nlp_service.py` para el asistente
- [ ] Actualizar `api_service.dart` en Flutter con los nuevos endpoints
- [ ] Crear las pantallas nuevas en Flutter, empezando por Dashboard y Captura de Factura
- [ ] Aplicar `AppTheme` con la paleta coral de Stock Flow
- [ ] Prueba end-to-end: foto de factura → backend → DB → respuesta en app

---

## 🔑 Dependencias Nuevas a Agregar

### Backend (`requirements.txt`)
```
anthropic>=0.25.0     # IA de visión y NLP
python-multipart      # ya existe para recibir imágenes — verificar
pillow                # procesamiento de imágenes
```

### Frontend (`pubspec.yaml`)
```yaml
dependencies:
  speech_to_text: ^6.6.0      # grabación de voz
  image_picker: ^1.0.7        # cámara y galería (posiblemente ya existe)
  google_fonts: ^6.1.0        # tipografías Lora + DM Sans
  fl_chart: ^0.68.0           # gráficas para reportes
  # http: ya existe en el proyecto base
```

---

> **Resumen:** El proyecto de detección de placas ya resolvió lo difícil — la arquitectura, la comunicación Flutter↔FastAPI, la cámara y los contenedores Docker. Stock Flow hereda todo eso y reemplaza únicamente la lógica de negocio: el modelo de CV por uno multimodal, el esquema de BD por uno de inventario, y las pantallas de placas por las de gestión de stock.
