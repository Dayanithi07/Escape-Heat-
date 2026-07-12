"""Authentication schemas."""

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr, Field


class UserRegisterRequest(BaseModel):
    """Registration request payload."""
    email: EmailStr = Field(..., description="User email address", examples=["user@example.com"])
    password: str = Field(..., min_length=8, description="Password (min 8 chars)")
    full_name: str = Field(..., min_length=2, description="Full name")


class UserLoginRequest(BaseModel):
    """Login request payload."""
    email: EmailStr = Field(..., description="User email address")
    password: str = Field(..., description="User password")


class UserResponse(BaseModel):
    """Public user profile."""
    id: str
    email: str
    full_name: str
    avatar_url: Optional[str] = None
    created_at: str


class AuthResponse(BaseModel):
    """Auth response with token and user info."""
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


class LogoutResponse(BaseModel):
    """Logout confirmation."""
    message: str = "Successfully logged out"
