from pydantic import BaseModel
from uuid import UUID
from datetime import datetime
from typing import Optional, List


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
