"""Map and geospatial schemas."""

from typing import Any, Dict, List, Optional

from pydantic import BaseModel


class HeatZoneProperties(BaseModel):
    zone_id: str
    name: str
    risk_level: str
    temperature: float
    heat_index: float
    color: str


class GeoJSONGeometry(BaseModel):
    type: str
    coordinates: Any


class HeatZoneFeature(BaseModel):
    type: str = "Feature"
    geometry: GeoJSONGeometry
    properties: HeatZoneProperties


class HeatZonesGeoJSON(BaseModel):
    """GeoJSON FeatureCollection of heat zones."""
    type: str = "FeatureCollection"
    features: List[HeatZoneFeature]


class PointOfInterest(BaseModel):
    """A point of interest (park, hospital, cooling center, water station)."""
    id: str
    name: str
    type: str
    lat: float
    lon: float
    address: str
    distance_km: float


class PointsOfInterestResponse(BaseModel):
    """List of nearby points of interest."""
    location: str
    radius_km: float
    points: List[PointOfInterest]
