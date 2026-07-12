"""Map endpoints."""

from typing import Optional

from fastapi import APIRouter, Depends, Query

from app.api.deps import get_map_service
from app.schemas.common import ApiResponse
from app.schemas.maps import HeatZonesGeoJSON, PointsOfInterestResponse
from app.services.map_service import MapService

router = APIRouter(prefix="/maps", tags=["Maps"])


@router.get(
    "/heat-zones",
    response_model=ApiResponse[HeatZonesGeoJSON],
    summary="Get heat zone map data",
    description="Returns GeoJSON data for heat zones around the specified location.",
)
async def get_heat_zones(
    lat: float = Query(13.0827, description="Latitude"),
    lon: float = Query(80.2707, description="Longitude"),
    radius_km: float = Query(10.0, ge=1, le=50, description="Search radius in km"),
    map_service: MapService = Depends(get_map_service),
):
    data = await map_service.get_heat_zones(lat, lon, radius_km)
    return ApiResponse(success=True, message="Heat zones retrieved", data=data)


@router.get(
    "/points-of-interest",
    response_model=ApiResponse[PointsOfInterestResponse],
    summary="Get nearby points of interest",
    description="Returns nearby parks, hospitals, cooling centers, and water stations.",
)
async def get_points_of_interest(
    lat: float = Query(13.0827, description="Latitude"),
    lon: float = Query(80.2707, description="Longitude"),
    radius_km: float = Query(5.0, ge=1, le=25, description="Search radius in km"),
    poi_type: Optional[str] = Query(
        None,
        description="Filter by type: park, hospital, cooling_center, water_station",
    ),
    map_service: MapService = Depends(get_map_service),
):
    data = await map_service.get_points_of_interest(lat, lon, radius_km, poi_type)
    return ApiResponse(
        success=True, message="Points of interest retrieved", data=data
    )
