# Escape Heat — Backend API

> AI-Powered Urban Heat Decision Intelligence Platform — FastAPI Backend

## 🚀 Quick Start

### Prerequisites

- Python 3.11+
- pip

### Installation

```bash
# Navigate to the backend directory
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# macOS/Linux:
# source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Copy environment file
copy .env.example .env
```

### Running the Server

```bash
python run.py
```

The API will be available at **http://localhost:8000**

## 📖 API Documentation

| Interface | URL |
|-----------|-----|
| Swagger UI | [http://localhost:8000/docs](http://localhost:8000/docs) |
| ReDoc | [http://localhost:8000/redoc](http://localhost:8000/redoc) |
| OpenAPI JSON | [http://localhost:8000/openapi.json](http://localhost:8000/openapi.json) |

## 🔐 Authentication

Protected endpoints require a Bearer token in the Authorization header:

```
Authorization: Bearer mock-jwt-token-escape-heat-2024
```

### Public Endpoints (No Auth Required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/` | Service info |
| `GET` | `/api/v1/health` | Health check |
| `POST` | `/api/v1/auth/register` | Register |
| `POST` | `/api/v1/auth/login` | Login |
| `GET` | `/api/v1/weather/current` | Current weather |
| `GET` | `/api/v1/weather/forecast` | Weather forecast |
| `GET` | `/api/v1/heat/analysis` | Heat analysis |
| `GET` | `/api/v1/heat/risk-score` | Risk score |
| `GET` | `/api/v1/maps/heat-zones` | Heat zone GeoJSON |
| `GET` | `/api/v1/maps/points-of-interest` | Nearby POIs |

### Protected Endpoints (Auth Required)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/auth/logout` | Logout |
| `GET` | `/api/v1/auth/me` | Current user profile |
| `GET` | `/api/v1/recommendations` | Personalized recommendations |
| `POST` | `/api/v1/ai/chat` | AI assistant chat |
| `GET` | `/api/v1/reports` | List reports |
| `GET` | `/api/v1/reports/{id}` | Get report details |
| `POST` | `/api/v1/reports` | Generate new report |
| `GET` | `/api/v1/history` | Activity history |

## 🏗️ Architecture

```
app/
├── api/            # Route handlers (HTTP layer)
│   ├── deps.py     # Dependency injection
│   └── v1/         # Versioned endpoints
├── core/           # Cross-cutting concerns
│   ├── exceptions.py
│   ├── exception_handlers.py
│   ├── logging_config.py
│   └── security.py
├── mock_data/      # Static mock data fixtures
├── repositories/   # Data access layer
├── schemas/        # Pydantic request/response models
└── services/       # Business logic layer
```

## 🧪 Testing

```bash
python -m pytest tests/ -v
```

## 📌 Notes

- All endpoints return **mock data** — no external APIs or databases are connected.
- Designed for **seamless integration** with Supabase, Gemini AI, and Open-Meteo in the production phase.
- CORS is configured for `localhost:3000` (Next.js frontend) and `localhost:5173` (Vite).
