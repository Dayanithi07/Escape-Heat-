"""Authentication service with mock implementation."""

import logging
from typing import Any, Dict

from app.config import settings
from app.core.exceptions import ConflictException, UnauthorizedException
from app.repositories.user_repository import UserRepository

logger = logging.getLogger(__name__)


class AuthService:
    """Handles user registration, login, and profile retrieval."""

    def __init__(self, user_repository: UserRepository) -> None:
        self._user_repo = user_repository

    async def register(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Register a new user (mock)."""
        existing = await self._user_repo.find_by_email(data["email"])
        if existing:
            raise ConflictException("A user with this email already exists")

        user = await self._user_repo.create(data)
        logger.info(f"User registered: {user['email']}")
        return {
            "access_token": settings.MOCK_JWT_TOKEN,
            "token_type": "bearer",
            "user": {
                "id": user["id"],
                "email": user["email"],
                "full_name": user["full_name"],
                "avatar_url": user.get("avatar_url"),
                "created_at": user["created_at"],
            },
        }

    async def login(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Authenticate a user (mock — accepts any registered email)."""
        user = await self._user_repo.find_by_email(data["email"])
        if not user:
            raise UnauthorizedException("Invalid email or password")

        logger.info(f"User logged in: {user['email']}")
        return {
            "access_token": settings.MOCK_JWT_TOKEN,
            "token_type": "bearer",
            "user": {
                "id": user["id"],
                "email": user["email"],
                "full_name": user["full_name"],
                "avatar_url": user.get("avatar_url"),
                "created_at": user["created_at"],
            },
        }

    async def logout(self, user_id: str) -> Dict[str, str]:
        """Logout (mock — just returns confirmation)."""
        logger.info(f"User logged out: {user_id}")
        return {"message": "Successfully logged out"}

    async def get_current_user(self, user: dict) -> Dict[str, Any]:
        """Return the current authenticated user profile."""
        return {
            "id": user["id"],
            "email": user["email"],
            "full_name": user["full_name"],
            "avatar_url": user.get("avatar_url"),
            "created_at": user["created_at"],
        }
