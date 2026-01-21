from pydantic import BaseModel
from uuid import UUID
from typing import Optional


class ProfileCreate(BaseModel):
    """Schema for creating/updating profile."""
    age: Optional[int] = None
    job: Optional[str] = None
    current_salary: Optional[float] = None
    fixed_costs: dict = {}  # {"rent": 500, "food": 200}
    financial_goals: dict = {}  # {"buy_house": 2030}


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
