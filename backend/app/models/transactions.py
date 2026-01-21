from sqlmodel import SQLModel, Field
from uuid import UUID, uuid4
from datetime import datetime
from typing import Optional
from enum import Enum


class TransactionType(str, Enum):
    """Transaction type enum."""
    INCOME = "INCOME"
    EXPENSE = "EXPENSE"


class TransactionCategory(str, Enum):
    """Transaction category enum."""
    FOOD = "FOOD"
    TRANSPORT = "TRANSPORT"
    SHOPPING = "SHOPPING"
    ENTERTAINMENT = "ENTERTAINMENT"
    BILLS = "BILLS"
    HEALTHCARE = "HEALTHCARE"
    EDUCATION = "EDUCATION"
    INCOME = "INCOME"
    SAVINGS = "SAVINGS"
    OTHER = "OTHER"


class Transaction(SQLModel, table=True):
    """Financial transaction model."""
    
    __tablename__ = "transactions"
    
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: UUID = Field(foreign_key="users.id", index=True)
    amount: float = Field(ge=0)
    category: str = Field(max_length=50)  # Use TransactionCategory values
    type: str = Field(max_length=20)  # Use TransactionType values
    transaction_date: datetime = Field(default_factory=datetime.utcnow, index=True)
    description: Optional[str] = Field(default=None, max_length=500)
