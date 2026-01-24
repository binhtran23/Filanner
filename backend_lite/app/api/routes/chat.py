from fastapi import APIRouter, Depends

from sqlmodel import Session
from app.api.deps import get_db, get_current_user
from app.models.users import User
from app.models.chat import ChatMessage, ChatResponse
from app.utils.ai_chat import generate_ai_response

router = APIRouter()


@router.post("/message", response_model=ChatResponse)
def chat_message(
    message_data: ChatMessage,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db)
):
    response = generate_ai_response(
        session,
        user_id=current_user.id,
        message=message_data.message
    )
    return response
