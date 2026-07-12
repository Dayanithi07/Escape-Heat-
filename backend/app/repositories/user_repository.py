"""Mock user repository."""

import copy
from typing import Any, Dict, List, Optional

from app.mock_data.users import MOCK_USERS
from app.repositories.base import BaseRepository


class UserRepository(BaseRepository[dict]):
    """In-memory user repository backed by mock data."""

    def __init__(self) -> None:
        self._users: List[dict] = copy.deepcopy(MOCK_USERS)

    async def find_all(self, **filters: Any) -> List[dict]:
        return self._users

    async def find_by_id(self, record_id: str) -> Optional[dict]:
        return next((u for u in self._users if u["id"] == record_id), None)

    async def find_by_email(self, email: str) -> Optional[dict]:
        return next((u for u in self._users if u["email"] == email), None)

    async def create(self, data: Dict[str, Any]) -> dict:
        new_user = {
            "id": f"usr_{len(self._users) + 1:03d}",
            **data,
            "avatar_url": f"https://api.dicebear.com/7.x/avataaars/svg?seed={data.get('full_name', 'user')}",
            "created_at": "2024-06-15T14:30:00Z",
            "preferences": {
                "temperature_unit": "celsius",
                "language": "en",
                "notifications_enabled": True,
            },
        }
        self._users.append(new_user)
        return new_user

    async def update(self, record_id: str, data: Dict[str, Any]) -> Optional[dict]:
        user = await self.find_by_id(record_id)
        if user:
            user.update(data)
        return user

    async def delete(self, record_id: str) -> bool:
        user = await self.find_by_id(record_id)
        if user:
            self._users.remove(user)
            return True
        return False
