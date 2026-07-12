"""History service with mock implementation."""

import logging
from typing import Any, Dict

from app.repositories.history_repository import HistoryRepository

logger = logging.getLogger(__name__)


class HistoryService:
    """Manages user activity history (mock)."""

    def __init__(self, history_repository: HistoryRepository) -> None:
        self._history_repo = history_repository

    async def get_history(
        self, user: dict, page: int = 1, page_size: int = 10
    ) -> Dict[str, Any]:
        """Get paginated user activity history."""
        items = await self._history_repo.find_all(page=page, page_size=page_size)
        total = await self._history_repo.count()
        logger.info(
            f"Retrieved history for user {user['id']}: page={page}, total={total}"
        )
        return {
            "items": items,
            "total": total,
            "page": page,
            "page_size": page_size,
        }
