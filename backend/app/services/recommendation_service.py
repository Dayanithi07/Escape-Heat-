"""Recommendation service with mock implementation."""

import logging
from typing import Any, Dict

from app.mock_data.recommendations import MOCK_RECOMMENDATIONS

logger = logging.getLogger(__name__)


class RecommendationService:
    """Generates personalized recommendations (mock)."""

    async def get_recommendations(
        self, lat: float, lon: float, user: dict | None = None
    ) -> Dict[str, Any]:
        """Get personalized heat safety recommendations."""
        logger.info(f"Generating recommendations for lat={lat}, lon={lon}")
        return {
            "location": "Chennai, Tamil Nadu",
            "risk_level": "extreme",
            "recommendations": MOCK_RECOMMENDATIONS,
            "generated_at": "2024-06-15T14:30:00Z",
        }
