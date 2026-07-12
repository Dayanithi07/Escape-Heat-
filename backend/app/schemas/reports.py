"""Report schemas."""

from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field


class ReportLocation(BaseModel):
    name: str
    lat: float
    lon: float


class ReportSection(BaseModel):
    title: str
    body: str


class ReportContent(BaseModel):
    summary: str
    sections: List[ReportSection]


class ReportSummary(BaseModel):
    """Brief report metadata for listing."""
    id: str
    title: str
    report_type: str
    location: ReportLocation
    created_at: str
    status: str


class ReportDetail(BaseModel):
    """Full report with content."""
    id: str
    title: str
    report_type: str
    location: ReportLocation
    content: ReportContent
    metrics: Dict[str, Any]
    created_at: str
    status: str


class ReportCreateRequest(BaseModel):
    """Request to generate a new report."""
    title: str = Field(..., min_length=5)
    report_type: str = Field(..., description="Type: daily_assessment, weekly_trend, custom")
    location_name: str
    lat: float
    lon: float


class ReportCreateResponse(BaseModel):
    """Confirmation of report creation."""
    id: str
    title: str
    status: str = "processing"
    message: str = "Report generation has been initiated"
