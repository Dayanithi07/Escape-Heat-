"""Heat analysis schemas."""

from typing import Any, Dict, List, Optional

from pydantic import BaseModel

from app.schemas.common import LocationBase


class ContributingFactor(BaseModel):
    """A single contributing factor to heat risk."""
    factor: str
    value: str
    impact: str
    description: str


class HeatAnalysisResponse(BaseModel):
    """Full heat analysis result."""
    location: LocationBase
    heat_index: float
    risk_level: str
    risk_category: str
    risk_score: int
    contributing_factors: List[ContributingFactor]
    analysis_summary: str
    recommendations_summary: List[str]
    timestamp: str


class RiskScoreFactors(BaseModel):
    """Breakdown of risk score components."""
    temperature_score: int
    humidity_score: int
    uv_score: int
    air_quality_score: int
    urban_heat_island_score: int


class ThresholdRange(BaseModel):
    min: int
    max: int
    color: str


class RiskScale(BaseModel):
    min: int
    max: int
    thresholds: Dict[str, ThresholdRange]


class RiskScoreResponse(BaseModel):
    """Heat risk score with breakdown."""
    location: LocationBase
    score: int
    level: str
    category: str
    color: str
    label: str
    factors: RiskScoreFactors
    scale: RiskScale
    timestamp: str
