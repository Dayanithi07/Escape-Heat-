"""History schemas."""

from typing import Any, Dict, List, Optional

from pydantic import BaseModel


class HistoryItem(BaseModel):
    """A single activity history entry."""
    id: str
    action: str
    description: str
    location: str
    timestamp: str
    metadata: Optional[Dict[str, Any]] = None


class HistoryResponse(BaseModel):
    """Paginated history response."""
    items: List[HistoryItem]
    total: int
    page: int
    page_size: int
