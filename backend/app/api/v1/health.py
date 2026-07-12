"""Health check endpoint."""

from datetime import datetime

from fastapi import APIRouter

from app.config import settings

router = APIRouter(tags=["Health"])


@router.get(
    "/health",
    summary="Health Check",
    description="Returns the current health status of the API server.",
)
async def health_check():
    return {
        "status": "healthy",
        "service": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "environment": "development" if settings.DEBUG else "production",
    }
