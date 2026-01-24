from sqlmodel import SQLModel
from pydantic import EmailStr
from uuid import UUID
from datetime import datetime
from typing import Optional


class UserCreate(SQLModel):
    """Schema for user registration."""
    username: str
    email: EmailStr
    password: str


class UserLogin(SQLModel):
    """Schema for user login."""
    username: str
    password: str


class Token(SQLModel):
    """Schema for JWT token response."""
    access_token: str
    token_type: str = "bearer"


class TokenData(SQLModel):
    """Schema for decoded JWT token data."""
    user_id: Optional[UUID] = None


class UserResponse(SQLModel):
    """Schema for user response."""
    id: UUID
    username: str
    email: str
    created_at: datetime
    total_points: int

    class Config:
        from_attributes = True
