from pydantic import BaseModel
from typing import Optional


class ChatMessage(BaseModel):
    """Schema for chat message."""
    message: str


class ChatResponse(BaseModel):
    """Schema for chat response."""
    message: str
    action: Optional[str] = None  # "ADJUST_PLAN", "SUGGEST_SAVING", etc.
    response_metadata: dict = {}  # Additional data like adjusted amounts
