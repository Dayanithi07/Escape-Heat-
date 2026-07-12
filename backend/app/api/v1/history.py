"""History endpoints."""

from fastapi import APIRouter, Depends, Query

from app.api.deps import get_history_service
from app.core.security import get_current_user
from app.schemas.common import ApiResponse
from app.schemas.history import HistoryResponse
from app.services.history_service import HistoryService

router = APIRouter(prefix="/history", tags=["History"])


@router.get(
    "",
    response_model=ApiResponse[HistoryResponse],
    summary="Get activity history",
    description="Returns the paginated activity history for the current user.",
)
async def get_history(
    page: int = Query(1, ge=1, description="Page number"),
    page_size: int = Query(10, ge=1, le=100, description="Items per page"),
    current_user: dict = Depends(get_current_user),
    history_service: HistoryService = Depends(get_history_service),
):
    data = await history_service.get_history(current_user, page, page_size)
    return ApiResponse(success=True, message="History retrieved", data=data)
