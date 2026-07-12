"""Weather schemas."""

from typing import List, Optional

from pydantic import BaseModel, Field

from app.schemas.common import LocationBase


class CurrentWeatherResponse(BaseModel):
    """Current weather conditions."""
    location: LocationBase
    temperature: float = Field(..., description="Temperature in Celsius")
    feels_like: float = Field(..., description="Feels-like temperature in Celsius")
    humidity: int = Field(..., description="Humidity percentage")
    wind_speed: float = Field(..., description="Wind speed in km/h")
    wind_direction: str
    uv_index: float
    air_quality_index: int
    air_quality_label: str
    description: str
    icon: str
    pressure: Optional[float] = None
    visibility: Optional[float] = None
    dew_point: Optional[float] = None
    timestamp: str


class ForecastDayResponse(BaseModel):
    """Single day forecast."""
    date: str
    temp_max: float
    temp_min: float
    humidity: int
    uv_index: float
    wind_speed: float
    description: str
    icon: str
    precipitation_chance: int = 0


class ForecastResponse(BaseModel):
    """Multi-day forecast."""
    location: LocationBase
    days: List[ForecastDayResponse]
