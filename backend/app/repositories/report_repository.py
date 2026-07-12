"""Mock report repository."""

import copy
from typing import Any, Dict, List, Optional

from app.mock_data.reports import MOCK_REPORTS
from app.repositories.base import BaseRepository


class ReportRepository(BaseRepository[dict]):
    """In-memory report repository backed by mock data."""

    def __init__(self) -> None:
        self._reports: List[dict] = copy.deepcopy(MOCK_REPORTS)

    async def find_all(self, **filters: Any) -> List[dict]:
        return self._reports

    async def find_by_id(self, record_id: str) -> Optional[dict]:
        return next((r for r in self._reports if r["id"] == record_id), None)

    async def create(self, data: Dict[str, Any]) -> dict:
        new_report = {
            "id": f"rpt_{len(self._reports) + 1:03d}",
            **data,
            "content": {
                "summary": f"Auto-generated report for {data.get('location_name', 'Unknown')}",
                "sections": [
                    {
                        "title": "Analysis",
                        "body": "This report is being processed. Full analysis will be available shortly.",
                    }
                ],
            },
            "metrics": {
                "max_temperature": 38.5,
                "heat_index": 48.5,
                "risk_score": 87,
            },
            "created_at": "2024-06-15T18:00:00Z",
            "status": "processing",
        }
        self._reports.append(new_report)
        return new_report

    async def update(self, record_id: str, data: Dict[str, Any]) -> Optional[dict]:
        report = await self.find_by_id(record_id)
        if report:
            report.update(data)
        return report

    async def delete(self, record_id: str) -> bool:
        report = await self.find_by_id(record_id)
        if report:
            self._reports.remove(report)
            return True
        return False
