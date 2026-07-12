"""Abstract base repository defining the data access interface."""

from abc import ABC, abstractmethod
from typing import Any, Dict, Generic, List, Optional, TypeVar

T = TypeVar("T")


class BaseRepository(ABC, Generic[T]):
    """Base repository interface.

    Concrete implementations will connect to Supabase.
    For now, all methods operate on in-memory mock data.
    """

    @abstractmethod
    async def find_all(self, **filters: Any) -> List[T]:
        """Retrieve all records, optionally filtered."""
        ...

    @abstractmethod
    async def find_by_id(self, record_id: str) -> Optional[T]:
        """Retrieve a single record by ID."""
        ...

    @abstractmethod
    async def create(self, data: Dict[str, Any]) -> T:
        """Create a new record."""
        ...

    @abstractmethod
    async def update(self, record_id: str, data: Dict[str, Any]) -> Optional[T]:
        """Update an existing record."""
        ...

    @abstractmethod
    async def delete(self, record_id: str) -> bool:
        """Delete a record by ID."""
        ...
