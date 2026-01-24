from sqlmodel import SQLModel, Field, Column
from sqlalchemy import JSON
from pydantic import BaseModel
from uuid import UUID, uuid4
from datetime import datetime
from typing import Optional, List


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
    gender: Optional[str] = Field(default=None, max_length=50)
    occupation: Optional[str] = Field(default=None, max_length=255)
    education_level: Optional[str] = Field(default=None, max_length=255)
    dependents: int = Field(default=0, ge=0)
    monthly_income: Optional[float] = Field(default=None, ge=0)
    other_income: Optional[float] = Field(default=None, ge=0)
    current_savings: Optional[float] = Field(default=0, ge=0)
    current_debt: Optional[float] = Field(default=None, ge=0)

    fixed_expenses: list = Field(default_factory=list, sa_column=Column(JSON))
    goals: list = Field(default_factory=list, sa_column=Column(JSON))
    risk_tolerance: Optional[str] = Field(default=None, max_length=50)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: Optional[datetime] = Field(default=None)


class FixedExpense(BaseModel):
    id: str
    name: str
    category: str
    amount: float
    description: Optional[str] = None


class FixedExpenseCreate(BaseModel):
    id: Optional[str] = None
    name: str
    category: str
    amount: float
    description: Optional[str] = None


class FixedExpenseUpdate(BaseModel):
    name: Optional[str] = None
    category: Optional[str] = None
    amount: Optional[float] = None
    description: Optional[str] = None


class ProfileCreate(BaseModel):
    """Schema for creating/updating profile."""
    age: Optional[int] = None
    gender: Optional[str] = None
    occupation: Optional[str] = None
    education_level: Optional[str] = None
    dependents: int = 0
    monthly_income: Optional[float] = None
    other_income: Optional[float] = None
    current_savings: Optional[float] = 0
    current_debt: Optional[float] = None
    fixed_expenses: List[FixedExpenseCreate] = Field(default_factory=list)
    goals: List[str] = Field(default_factory=list)
    risk_tolerance: Optional[str] = None


class ProfileUpdate(BaseModel):
    """Schema for partial profile updates."""
    age: Optional[int] = None
    gender: Optional[str] = None
    occupation: Optional[str] = None
    education_level: Optional[str] = None
    dependents: Optional[int] = None
    monthly_income: Optional[float] = None
    other_income: Optional[float] = None
    current_savings: Optional[float] = None
    current_debt: Optional[float] = None
    fixed_expenses: Optional[List[FixedExpenseCreate]] = None
    goals: Optional[List[str]] = None
    risk_tolerance: Optional[str] = None


class ProfileResponse(BaseModel):
    """Schema for profile response."""
    id: UUID
    user_id: UUID
    age: Optional[int]
    gender: Optional[str]
    occupation: Optional[str]
    education_level: Optional[str]
    dependents: int
    monthly_income: Optional[float]
    other_income: Optional[float]
    current_savings: Optional[float]
    current_debt: Optional[float]
    fixed_expenses: List[FixedExpense]
    goals: List[str]
    risk_tolerance: Optional[str]
    created_at: datetime
    updated_at: Optional[datetime]

    class Config:
        from_attributes = True
