"""Central router that aggregates all API v1 routes."""

from fastapi import APIRouter

from app.api.v1 import (
    ai_chat,
    auth,
    health,
    heat_analysis,
    history,
    maps,
    recommendations,
    reports,
    weather,
)

api_router = APIRouter()

# Include all v1 route modules
api_router.include_router(health.router)
api_router.include_router(auth.router)
api_router.include_router(weather.router)
api_router.include_router(heat_analysis.router)
api_router.include_router(recommendations.router)
api_router.include_router(ai_chat.router)
api_router.include_router(reports.router)
api_router.include_router(history.router)
api_router.include_router(maps.router)
