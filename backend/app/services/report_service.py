"""Report service with mock implementation."""

import logging
from typing import Any, Dict, List

from app.core.exceptions import NotFoundException
from app.repositories.report_repository import ReportRepository

logger = logging.getLogger(__name__)


class ReportService:
    """Manages report generation and retrieval (mock)."""

    def __init__(self, report_repository: ReportRepository) -> None:
        self._report_repo = report_repository

    async def list_reports(self, user: dict) -> List[Dict[str, Any]]:
        """List all reports for the current user."""
        reports = await self._report_repo.find_all()
        logger.info(f"Listed {len(reports)} reports for user {user['id']}")
        return [
            {
                "id": r["id"],
                "title": r["title"],
                "report_type": r["report_type"],
                "location": r["location"],
                "created_at": r["created_at"],
                "status": r["status"],
            }
            for r in reports
        ]

    async def get_report(self, report_id: str, user: dict) -> Dict[str, Any]:
        """Get a single report by ID."""
        report = await self._report_repo.find_by_id(report_id)
        if not report:
            raise NotFoundException(f"Report '{report_id}' not found")
        logger.info(f"Retrieved report {report_id} for user {user['id']}")
        return report

    async def create_report(self, data: Dict[str, Any], user: dict) -> Dict[str, Any]:
        """Create a new report."""
        report = await self._report_repo.create(data)
        logger.info(f"Created report {report['id']} for user {user['id']}")
        return {
            "id": report["id"],
            "title": report.get("title", data.get("title")),
            "status": "processing",
            "message": "Report generation has been initiated",
        }
