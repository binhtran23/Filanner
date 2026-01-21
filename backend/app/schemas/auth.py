from pydantic import BaseModel, EmailStr
from uuid import UUID
from datetime import datetime
from typing import Optional


# Auth Schemas
class UserCreate(BaseModel):
    """Schema for user registration."""
    username: str
    email: EmailStr
    password: str


class UserLogin(BaseModel):
    """Schema for user login."""
    username: str
    password: str


class Token(BaseModel):
    """Schema for JWT token response."""
    access_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    """Schema for decoded JWT token data."""
    user_id: Optional[UUID] = None


# User Schemas
class UserResponse(BaseModel):
    """Schema for user response."""
    id: UUID
    username: str
    email: str
    created_at: datetime
    total_points: int
    
    class Config:
        from_attributes = True
