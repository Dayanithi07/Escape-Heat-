"""Map service with mock implementation."""

import logging
from typing import Any, Dict, List, Optional

from app.mock_data.maps import MOCK_HEAT_ZONES, MOCK_POINTS_OF_INTEREST

logger = logging.getLogger(__name__)


class MapService:
    """Provides geospatial heat zone and POI data (mock)."""

    async def get_heat_zones(
        self, lat: float, lon: float, radius_km: float = 10.0
    ) -> Dict[str, Any]:
        """Get heat zone GeoJSON data for a location."""
        logger.info(
            f"Fetching heat zones for lat={lat}, lon={lon}, radius={radius_km}km"
        )
        return MOCK_HEAT_ZONES

    async def get_points_of_interest(
        self,
        lat: float,
        lon: float,
        radius_km: float = 5.0,
        poi_type: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Get nearby points of interest."""
        logger.info(
            f"Fetching POIs for lat={lat}, lon={lon}, radius={radius_km}km, type={poi_type}"
        )
        points = MOCK_POINTS_OF_INTEREST
        if poi_type:
            points = [p for p in points if p["type"] == poi_type]

        return {
            "location": "Chennai, Tamil Nadu",
            "radius_km": radius_km,
            "points": points,
        }
