from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user
from app.models.users import User
from app.schemas.chat import ChatMessage, ChatResponse
from app.utils.ai_chat import generate_ai_response

router = APIRouter()


@router.post("/message", response_model=ChatResponse)
async def chat_message(
    message_data: ChatMessage,
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    """
    AI Advisor chat endpoint.
    Example: "Tháng này tôi lỡ tiêu lố 5 triệu tiền giày, giờ sao?"
    """
    # Generate AI response (stub for now)
    response = await generate_ai_response(
        session,
        user_id=current_user.id,
        message=message_data.message
    )
    
    return response
