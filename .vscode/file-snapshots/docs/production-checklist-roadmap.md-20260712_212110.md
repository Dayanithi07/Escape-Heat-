# Escape Heat Production Checklist & Developer Guide

## Current Status

Escape Heat is currently in a strong demo/MVP state.

What is already in place:
- Next.js frontend with multiple pages and a polished UI
- FastAPI backend with versioned routes
- Mock data and mock services for weather, heat analysis, maps, recommendations, reports, history, and auth
- Local CORS support for the frontend dev server
- Basic documentation for both frontend and backend

What is not yet production-ready:
- Real database persistence
- Real authentication flow
- Live weather and environmental API integration
- Real AI provider integration
- Production deployment and observability
- Automated CI/CD and release validation

## Priority 1: Terminal / Workspace Error Check

Status at the time of writing:
- No workspace errors were found in the current project files.
- The Python environment check completed successfully.

If you see a terminal error later, check these first:
- Backend environment variables in `backend/.env`
- Python virtual environment activation
- Node.js dependencies in `escape-heat`
- Port conflicts on `3000` and `8000`

## Production Checklist Roadmap

### Phase 1: Data and API Integration
- Replace mock weather data with live Open-Meteo / NASA POWER / IMD integrations
- Connect map layers to real geospatial data sources
- Replace mock recommendation generation with service-backed logic
- Wire the AI assistant to a real LLM provider such as Gemini
- Add request validation and retries for external APIs

### Phase 2: Authentication and Persistence
- Replace mock auth with Supabase Auth
- Persist users, profiles, saved locations, reports, and history in PostgreSQL
- Add real access control and user session handling
- Store uploaded or generated artifacts in Supabase Storage

### Phase 3: Backend Hardening
- Add caching for expensive API calls
- Add rate limiting and timeouts
- Improve error handling and fallback behavior
- Add structured logging and request tracing
- Add database migration and seed workflows for production

### Phase 4: Frontend Production Readiness
- Replace mock data calls with API hooks
- Add loading, empty, and error states for all data-driven pages
- Verify responsive behavior on mobile and desktop
- Improve accessibility and keyboard navigation
- Confirm route-level auth handling for protected pages

### Phase 5: Testing and Quality Gates
- Add unit tests for services and utilities
- Add API integration tests for all major endpoints
- Add frontend component and page tests
- Add smoke tests for login, dashboard, map, and assistant flows
- Add lint, type-check, and test checks in CI

### Phase 6: Deployment and Operations
- Configure environment-specific settings for dev, staging, and production
- Add CI/CD pipelines
- Deploy frontend to Vercel or equivalent
- Deploy backend to Render or equivalent
- Set up monitoring, alerts, and log aggregation
- Define backup and recovery strategy for the database

## Developer Guide: Setup and Run Locally

### Prerequisites
- Python 3.11 or newer
- Node.js 18+ recommended
- npm or another Node package manager

### 1) Clone or open the repository
Open the workspace root:
- `D:\Project\July participation\Gen AI cohort Hackathon\Escape Heat`

### 2) Run the backend
From the project root:

```bash
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
python run.py
```

Backend URLs:
- API root: `http://localhost:8000`
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

### 3) Run the frontend
Open a second terminal from the project root:

```bash
cd escape-heat
npm install
npm run dev
```

Frontend URL:
- `http://localhost:3000`

### 4) Run tests and checks
Backend:

```bash
cd backend
python -m pytest tests/ -v
```

Frontend:

```bash
cd escape-heat
npm run lint
npm run build
```

## Environment Variables

### Backend
The backend reads from `backend/.env`.
Typical values:
- `APP_NAME`
- `APP_VERSION`
- `DEBUG`
- `HOST`
- `PORT`
- `CORS_ORIGINS`
- `SUPABASE_URL`
- `SUPABASE_KEY`
- `GEMINI_API_KEY`
- `WEATHER_API_URL`

### Frontend
Add frontend env vars as needed for API integration:
- `NEXT_PUBLIC_API_URL`
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`

## Useful Endpoints

Backend public endpoints:
- `GET /`
- `GET /api/v1/health`
- `GET /api/v1/weather/current`
- `GET /api/v1/weather/forecast`
- `GET /api/v1/heat/analysis`
- `GET /api/v1/maps/heat-zones`

Protected examples:
- `GET /api/v1/auth/me`
- `GET /api/v1/recommendations`
- `POST /api/v1/ai/chat`
- `GET /api/v1/reports`
- `GET /api/v1/history`

## Suggested Production Order

1. Connect real data sources
2. Replace mock auth and storage
3. Add production error handling and caching
4. Wire frontend to backend APIs
5. Add testing and CI/CD
6. Deploy to staging
7. Validate end-to-end flows
8. Promote to production

## Final Readiness Check

Before production release, confirm:
- No mock services remain in user-facing flows
- Environment variables are set in all environments
- Health checks and logs are working
- Authentication and authorization are enforced
- Database migrations run cleanly
- Frontend and backend are deployed and reachable
- Key user journeys work end to end
