from sqlmodel import SQLModel, Field, Column
from sqlalchemy import JSON
from uuid import UUID, uuid4
from datetime import datetime
from typing import Optional
from enum import Enum


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


class PlanNode(SQLModel, table=True):
    """Plan node model - represents a step in a financial plan."""
    
    __tablename__ = "plan_nodes"
    
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    plan_id: UUID = Field(foreign_key="financial_plans.id", index=True)
    parent_node_id: Optional[UUID] = Field(
        default=None, 
        foreign_key="plan_nodes.id"
    )  # Link to previous step (nullable)
    
    title: str = Field(max_length=255)  # "Tiết kiệm tháng 1"
    node_type: str = Field(max_length=20)  # Use NodeType values
    target_amount: Optional[float] = Field(default=None, ge=0)
    current_amount: float = Field(default=0, ge=0)
    status: str = Field(default=NodeStatus.PENDING.value, max_length=20)
    
    # AI suggestions and other flexible data
    node_metadata: dict = Field(default_factory=dict, sa_column=Column(JSON))
    
    deadline: Optional[datetime] = Field(default=None)
    created_at: datetime = Field(default_factory=datetime.utcnow)
