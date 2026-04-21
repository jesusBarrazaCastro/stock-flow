# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Stock Flow is an inventory management system with AI-powered features (invoice OCR via camera, voice input, NLP assistant). It consists of a Flutter mobile frontend, a FastAPI backend, and a PostgreSQL database.

## Commands

### Backend

```bash
# Run locally (from project root)
source .venv/bin/activate
cd backend
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Run with Docker
docker-compose up -d stockflow-backend
docker-compose logs -f stockflow-backend

# Health check
curl http://localhost:8000/health
```

### Frontend (Flutter)

```bash
cd frontend/stock_flow
flutter pub get
flutter run

# Build
flutter build apk --release
flutter build ios --release

# Test
flutter test
flutter test test/widget_test.dart  # single test file
```

### Database

Apply the schema to a fresh PostgreSQL database:
```bash
psql -U postgres -d stockflow_db -f database_scripts/stock_flow_database.sql
```

## Environment Variables

Backend reads from environment (`.env` file or docker-compose):
```
DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
SECRET_KEY                    # JWT signing key
ACCESS_TOKEN_EXPIRE_MINUTES   # default 1440 (24h)
ANTHROPIC_API_KEY             # required for vision & NLP features
```

Frontend reads from `.env` file at root of Flutter project (`frontend/stock_flow/.env`).

## Architecture

### Backend (`backend/app/`)

FastAPI app with 5 routers, all mounted under `/api`:

| Router | Prefix | Key endpoints |
|--------|--------|---------------|
| `api/auth.py` | `/auth` | POST `/login`, POST `/register`, GET `/me` |
| `api/productos.py` | `/productos` | GET `/`, POST `/` |
| `api/movimientos.py` | `/movimientos` | POST `/` (ENTRADA/SALIDA) |
| `api/vision.py` | `/vision` | POST `/leer-factura/` — invoice OCR |
| `api/asistente.py` | `/asistente` | POST `/consultar/` — NLP Q&A |

- **`core/security.py`** — JWT (HS256) creation/validation + bcrypt password hashing via passlib
- **`services/db_service.py`** — psycopg2 connection with `RealDictCursor`; all DB access via `execute_query(sql, params, fetchone, fetchall, commit)`
- **`services/vision_service.py`** — Claude API (`claude-3-opus-20240229`) for invoice image → JSON extraction
- **`services/nlp_service.py`** — Claude API (`claude-3-haiku-20240307`) for Spanish-language inventory Q&A
- **`models/schemas.py`** — Pydantic models for all request/response validation

CORS is configured to allow all origins (development setup).

### Frontend (`frontend/stock_flow/lib/`)

Flutter app using **Provider** for state management.

**Auth flow:** `main.dart` reads JWT from `flutter_secure_storage` via `AuthProvider` → routes to `LoginScreen` or `MainNavigation`.

**Navigation:** `MainNavigation` provides a `BottomNavigationBar` (4 tabs) + persistent FAB for registration:
- Dashboard → `DashboardScreen` (KPIs, alerts, recent activity)
- Stock → `StockScreen` (product list by category)
- Data → `DataScreen` (charts, reports)
- Profile → `ProfileScreen`

**Registration methods** (selected from `RegisterSelectionScreen`):
- Manual form → `ManualRegistrationScreen`
- Invoice photo → `CameraRegistrationScreen` (calls `/api/vision/leer-factura/`)
- Voice → `VoiceRegistrationScreen`

**API client:** `api_service.dart` — base URL is an ngrok tunnel URL (update this when running locally). `core/network/api_client.dart` handles token injection.

**Theme:** Dark, defined in `app_theme.dart` — background `#1E222D`, accent `#4DB6AC` (teal).

## Architectural Pattern: SP-AC (Stored Procedure + Action)

**All business logic lives in the database.** Every feature must follow this flow:

```
Flutter (params) → FastAPI router (validates + calls SP) → PostgreSQL SP (executes transactionally) → JSONB response
```

### Rules — no exceptions

1. **Database:** create a `write_<entity>` or `read_<entity>` PL/pgSQL function per entity. Each function receives `p_ac TEXT` as first parameter to dispatch actions (e.g. `'register'`, `'login'`, `'update'`, `'delete'`). All logic — inserts, updates, lookups, error checks — happens inside the SP within a single transaction.

2. **Backend:** the router receives the request, validates with a Pydantic schema, then calls `execute_query()` with the SP and returns the JSONB result. No business logic in Python — only input validation and auth checks.

3. **Frontend:** sends the required params to the endpoint. Does not know the SP name or AC; that decision belongs to the backend.

### SP naming convention

| Type | Name pattern | Example |
|------|-------------|---------|
| Writes (INSERT/UPDATE/DELETE) | `write_<entity>(p_ac, ...)` | `write_usuarios('register', ...)` |
| Reads (SELECT) | `read_<entity>(p_ac, ...)` | `read_usuarios('login', ...)` |

### SP return contract

SPs always return `JSONB`. On error: `{"error": "mensaje"}`. On success: the relevant data object.

The backend checks for the `"error"` key and raises `HTTPException` accordingly — never let a DB error reach the client as a 200.

### Example (auth — already implemented)

```sql
-- database_scripts/auth_functions.sql
SELECT write_usuarios('register', p_nombre, p_negocio, p_email, p_password_hash)
SELECT read_usuarios('login', p_email)
SELECT read_usuarios('me', p_email)
```

```python
# backend/app/api/auth.py
result = execute_query("SELECT write_usuarios(%s,%s,%s,%s,%s) AS r",
                       ('register', data.nombre, data.negocio, data.email, hashed),
                       fetchone=True)
if result["r"].get("error"):
    raise HTTPException(status_code=400, detail=result["r"]["error"])
```

New SP files go in `database_scripts/` and must be applied to the DB before deploying the backend.

---

### Database

15 tables + 3 views. Key tables:
- `empresas` / `usuarios` / `roles` — multi-tenant with role-based permissions (JSONB)
- `productos` / `inventario` — product master and per-warehouse stock levels
- `movimientos_inventario` — immutable transaction log (tipo: ENTRADA/SALIDA, metodo_registro: MANUAL/VOZ/CAMARA)
- `alertas_stock` — auto-generated alerts (AGOTADO/STOCK_BAJO/EXCESO)
- `log_actividad` — full audit trail

Key views: `v_stock_productos` (stock status per product), `v_dashboard_kpis`, `v_actividad_reciente`.

All tables have audit columns: `registro_fecha`, `registro_estado`, `registro_usuario`.
