from sqlmodel import SQLModel, Field, Column
from sqlalchemy import JSON
from pydantic import BaseModel
from uuid import UUID, uuid4
from datetime import datetime
from typing import Optional, List
from enum import Enum


class PlanStatus(str, Enum):
    """Financial plan status enum."""
    ACTIVE = "ACTIVE"
    ARCHIVED = "ARCHIVED"


class NodeType(str, Enum):
    """Plan node type enum."""
    MILESTONE = "MILESTONE"
    ACTION = "ACTION"
    ADJUSTMENT = "ADJUSTMENT"


class NodeStatus(str, Enum):
    """Plan node status enum."""
    PENDING = "PENDING"
    COMPLETED = "COMPLETED"
    SKIPPED = "SKIPPED"


class FinancialPlan(SQLModel, table=True):
    """Financial planning model."""

    __tablename__ = "financial_plans"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: UUID = Field(foreign_key="users.id", index=True)
    name: str = Field(max_length=255)  # "Plan mua nha 2025"
    status: str = Field(default=PlanStatus.ACTIVE.value, max_length=20)
    created_at: datetime = Field(default_factory=datetime.utcnow)


class PlanNode(SQLModel, table=True):
    """Plan node model - represents a step in a financial plan."""

    __tablename__ = "plan_nodes"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    plan_id: UUID = Field(foreign_key="financial_plans.id", index=True)
    parent_node_id: Optional[UUID] = Field(default=None, foreign_key="plan_nodes.id")
    title: str = Field(max_length=255)
    node_type: str = Field(max_length=20)
    target_amount: Optional[float] = Field(default=None, ge=0)
    current_amount: float = Field(default=0, ge=0)
    status: str = Field(default=NodeStatus.PENDING.value, max_length=20)
    node_metadata: dict = Field(default_factory=dict, sa_column=Column(JSON))
    deadline: Optional[datetime] = Field(default=None)
    created_at: datetime = Field(default_factory=datetime.utcnow)


class PlanCreate(BaseModel):
    """Schema for creating a financial plan."""
    name: str


class PlanNodeResponse(BaseModel):
    """Schema for plan node response."""
    id: UUID
    plan_id: UUID
    parent_node_id: Optional[UUID]
    title: str
    node_type: str
    target_amount: Optional[float]
    current_amount: float
    status: str
    node_metadata: dict
    deadline: Optional[datetime]
    created_at: datetime

    class Config:
        from_attributes = True


class PlanResponse(BaseModel):
    """Schema for financial plan response."""
    id: UUID
    user_id: UUID
    name: str
    status: str
    created_at: datetime
    nodes: List[PlanNodeResponse] = []

    class Config:
        from_attributes = True


class NodeUpdate(BaseModel):
    """Schema for updating a plan node."""
    status: Optional[str] = None
    current_amount: Optional[float] = None
