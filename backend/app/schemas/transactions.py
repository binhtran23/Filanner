from pydantic import BaseModel
from uuid import UUID
from datetime import datetime
from typing import Optional


class TransactionCreate(BaseModel):
    """Schema for creating a transaction."""
    amount: float
    category: str  # FOOD, TRANSPORT, etc.
    type: str  # INCOME / EXPENSE
    transaction_date: Optional[datetime] = None
    description: Optional[str] = None


class TransactionResponse(BaseModel):
    """Schema for transaction response."""
    id: UUID
    user_id: UUID
    amount: float
    category: str
    type: str
    transaction_date: datetime
    description: Optional[str]
    
    class Config:
        from_attributes = True


class TransactionSummary(BaseModel):
    """Schema for transaction summary."""
    total_income: float
    total_expense: float
    net_amount: float
    by_category: dict  # {"FOOD": 200, "TRANSPORT": 100}
