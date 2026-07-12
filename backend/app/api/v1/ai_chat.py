"""AI Chat endpoints."""

from fastapi import APIRouter, Depends

from app.api.deps import get_ai_chat_service
from app.core.security import get_current_user
from app.schemas.ai_chat import ChatMessageRequest, ChatMessageResponse
from app.schemas.common import ApiResponse
from app.services.ai_chat_service import AIChatService

router = APIRouter(prefix="/ai", tags=["AI Chat"])


@router.post(
    "/chat",
    response_model=ApiResponse[ChatMessageResponse],
    summary="Chat with the AI assistant",
    description="Send a message to the Escape Heat AI assistant and receive a context-aware response.",
)
async def chat(
    payload: ChatMessageRequest,
    current_user: dict = Depends(get_current_user),
    chat_service: AIChatService = Depends(get_ai_chat_service),
):
    data = await chat_service.chat(
        message=payload.message,
        context=payload.context,
        user=current_user,
    )
    return ApiResponse(success=True, message="Response generated", data=data)
