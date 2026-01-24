from sqlmodel import SQLModel, Field, Column
from sqlalchemy import JSON
from pydantic import BaseModel
from uuid import UUID, uuid4
from datetime import datetime
from typing import Optional


class User(SQLModel, table=True):
    """User model for authentication and profile."""

    __tablename__ = "users"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    username: str = Field(unique=True, index=True, max_length=100)
    hashed_password: str = Field(max_length=255)
    email: str = Field(unique=True, index=True, max_length=255)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    total_points: int = Field(default=0)


class Profile(SQLModel, table=True):
    """User profile with financial information."""

    __tablename__ = "profiles"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: UUID = Field(foreign_key="users.id", unique=True, index=True)
    age: Optional[int] = Field(default=None, ge=0, le=150)
    job: Optional[str] = Field(default=None, max_length=255)
    current_salary: Optional[float] = Field(default=None, ge=0)

    fixed_costs: dict = Field(default_factory=dict, sa_column=Column(JSON))
    financial_goals: dict = Field(default_factory=dict, sa_column=Column(JSON))


class ProfileCreate(BaseModel):
    """Schema for creating/updating profile."""
    age: Optional[int] = None
    job: Optional[str] = None
    current_salary: Optional[float] = None
    fixed_costs: dict = {}
    financial_goals: dict = {}


class ProfileResponse(BaseModel):
    """Schema for profile response."""
    id: UUID
    user_id: UUID
    age: Optional[int]
    job: Optional[str]
    current_salary: Optional[float]
    fixed_costs: dict
    financial_goals: dict

    class Config:
        from_attributes = True
