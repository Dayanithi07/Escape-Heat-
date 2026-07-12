"""AI Chat schemas."""

from typing import Dict, List, Optional

from pydantic import BaseModel, Field


class ChatMessageRequest(BaseModel):
    """Incoming chat message from user."""
    message: str = Field(..., min_length=1, max_length=2000, description="User's message")
    context: Optional[Dict] = Field(None, description="Optional context (location, weather)")


class ChatMessageResponse(BaseModel):
    """AI chat response."""
    response: str
    sources: Optional[List[str]] = None
    suggested_questions: Optional[List[str]] = None
    timestamp: str
