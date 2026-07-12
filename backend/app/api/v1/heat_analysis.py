"""Heat analysis endpoints."""

from fastapi import APIRouter, Depends, Query

from app.api.deps import get_heat_analysis_service
from app.schemas.common import ApiResponse
from app.schemas.heat_analysis import HeatAnalysisResponse, RiskScoreResponse
from app.services.heat_analysis_service import HeatAnalysisService

router = APIRouter(prefix="/heat", tags=["Heat Analysis"])


@router.get(
    "/analysis",
    response_model=ApiResponse[HeatAnalysisResponse],
    summary="Get heat analysis",
    description="Returns a comprehensive heat analysis for the specified location.",
)
async def get_heat_analysis(
    lat: float = Query(13.0827, description="Latitude"),
    lon: float = Query(80.2707, description="Longitude"),
    heat_service: HeatAnalysisService = Depends(get_heat_analysis_service),
):
    data = await heat_service.get_analysis(lat, lon)
    return ApiResponse(success=True, message="Heat analysis retrieved", data=data)


@router.get(
    "/risk-score",
    response_model=ApiResponse[RiskScoreResponse],
    summary="Get heat risk score",
    description="Returns the heat risk score with factor breakdown for a location.",
)
async def get_risk_score(
    lat: float = Query(13.0827, description="Latitude"),
    lon: float = Query(80.2707, description="Longitude"),
    heat_service: HeatAnalysisService = Depends(get_heat_analysis_service),
):
    data = await heat_service.get_risk_score(lat, lon)
    return ApiResponse(success=True, message="Risk score calculated", data=data)
