"""Mock history repository."""

import copy
from typing import Any, Dict, List, Optional

from app.mock_data.history import MOCK_HISTORY
from app.repositories.base import BaseRepository


class HistoryRepository(BaseRepository[dict]):
    """In-memory history repository backed by mock data."""

    def __init__(self) -> None:
        self._history: List[dict] = copy.deepcopy(MOCK_HISTORY)

    async def find_all(self, **filters: Any) -> List[dict]:
        page = filters.get("page", 1)
        page_size = filters.get("page_size", 10)
        start = (page - 1) * page_size
        end = start + page_size
        return self._history[start:end]

    async def count(self) -> int:
        return len(self._history)

    async def find_by_id(self, record_id: str) -> Optional[dict]:
        return next((h for h in self._history if h["id"] == record_id), None)

    async def create(self, data: Dict[str, Any]) -> dict:
        new_entry = {
            "id": f"hist_{len(self._history) + 1:03d}",
            **data,
        }
        self._history.insert(0, new_entry)
        return new_entry

    async def update(self, record_id: str, data: Dict[str, Any]) -> Optional[dict]:
        entry = await self.find_by_id(record_id)
        if entry:
            entry.update(data)
        return entry

    async def delete(self, record_id: str) -> bool:
        entry = await self.find_by_id(record_id)
        if entry:
            self._history.remove(entry)
            return True
        return False
