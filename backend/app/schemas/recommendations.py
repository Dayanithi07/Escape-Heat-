"""Recommendation schemas."""

from typing import List

from pydantic import BaseModel


class RecommendationItem(BaseModel):
    """A single recommendation."""
    id: str
    category: str
    title: str
    description: str
    priority: str
    icon: str


class RecommendationsResponse(BaseModel):
    """Full recommendation list."""
    location: str
    risk_level: str
    recommendations: List[RecommendationItem]
    generated_at: str
