"""Recommendation endpoints."""

from fastapi import APIRouter, Depends, Query

from app.api.deps import get_recommendation_service
from app.core.security import get_current_user
from app.schemas.common import ApiResponse
from app.schemas.recommendations import RecommendationsResponse
from app.services.recommendation_service import RecommendationService

router = APIRouter(prefix="/recommendations", tags=["Recommendations"])


@router.get(
    "",
    response_model=ApiResponse[RecommendationsResponse],
    summary="Get personalized recommendations",
    description="Returns personalized heat safety recommendations based on current conditions and user profile.",
)
async def get_recommendations(
    lat: float = Query(13.0827, description="Latitude"),
    lon: float = Query(80.2707, description="Longitude"),
    current_user: dict = Depends(get_current_user),
    rec_service: RecommendationService = Depends(get_recommendation_service),
):
    data = await rec_service.get_recommendations(lat, lon, current_user)
    return ApiResponse(
        success=True, message="Recommendations generated", data=data
    )
