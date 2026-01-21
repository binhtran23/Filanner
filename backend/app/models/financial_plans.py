from sqlmodel import SQLModel, Field
from uuid import UUID, uuid4
from datetime import datetime
from typing import Optional
from enum import Enum


class PlanStatus(str, Enum):
    """Financial plan status enum."""
    ACTIVE = "ACTIVE"
    ARCHIVED = "ARCHIVED"


class FinancialPlan(SQLModel, table=True):
    """Financial planning model."""
    
    __tablename__ = "financial_plans"
    
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: UUID = Field(foreign_key="users.id", index=True)
    name: str = Field(max_length=255)  # "Plan mua nhà 2025"
    status: str = Field(default=PlanStatus.ACTIVE.value, max_length=20)
    created_at: datetime = Field(default_factory=datetime.utcnow)
