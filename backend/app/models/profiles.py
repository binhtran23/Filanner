from sqlmodel import SQLModel, Field, Column
from sqlalchemy import JSON
from uuid import UUID, uuid4
from typing import Optional


class Profile(SQLModel, table=True):
    """User profile with financial information."""
    
    __tablename__ = "profiles"
    
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: UUID = Field(foreign_key="users.id", unique=True, index=True)
    age: Optional[int] = Field(default=None, ge=0, le=150)
    job: Optional[str] = Field(default=None, max_length=255)
    current_salary: Optional[float] = Field(default=None, ge=0)
    
    # JSON fields for flexible data storage
    fixed_costs: dict = Field(default_factory=dict, sa_column=Column(JSON))
    # Example: {"rent": 500, "food": 200, "transport": 100}
    
    financial_goals: dict = Field(default_factory=dict, sa_column=Column(JSON))
    # Example: {"buy_house": 2030, "retirement": 2050}
