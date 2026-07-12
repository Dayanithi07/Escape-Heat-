"""Weather endpoints."""

from fastapi import APIRouter, Depends, Query

from app.api.deps import get_weather_service
from app.schemas.common import ApiResponse
from app.schemas.weather import CurrentWeatherResponse, ForecastResponse
from app.services.weather_service import WeatherService

router = APIRouter(prefix="/weather", tags=["Weather"])


@router.get(
    "/current",
    response_model=ApiResponse[CurrentWeatherResponse],
    summary="Get current weather",
    description="Returns current weather conditions for the specified location.",
)
async def get_current_weather(
    lat: float = Query(13.0827, description="Latitude"),
    lon: float = Query(80.2707, description="Longitude"),
    weather_service: WeatherService = Depends(get_weather_service),
):
    data = await weather_service.get_current_weather(lat, lon)
    return ApiResponse(success=True, message="Current weather retrieved", data=data)


@router.get(
    "/forecast",
    response_model=ApiResponse[ForecastResponse],
    summary="Get weather forecast",
    description="Returns a multi-day weather forecast for the specified location.",
)
async def get_forecast(
    lat: float = Query(13.0827, description="Latitude"),
    lon: float = Query(80.2707, description="Longitude"),
    days: int = Query(5, ge=1, le=7, description="Number of forecast days"),
    weather_service: WeatherService = Depends(get_weather_service),
):
    data = await weather_service.get_forecast(lat, lon, days)
    return ApiResponse(success=True, message="Forecast retrieved", data=data)
