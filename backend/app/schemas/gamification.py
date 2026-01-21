from pydantic import BaseModel
from uuid import UUID
from datetime import date, datetime
from typing import Optional


class CheckInResponse(BaseModel):
    """Schema for check-in response."""
    streak: int
    asset_url: str
    points_added: int
    check_in_date: date
    
    class Config:
        from_attributes = True


class RewardResponse(BaseModel):
    """Schema for reward response."""
    id: UUID
    name: str
    cost_point: int
    image_url: Optional[str]
    description: Optional[str]
    
    class Config:
        from_attributes = True


class RedeemRequest(BaseModel):
    """Schema for redeeming a reward."""
    reward_id: UUID


class RedeemResponse(BaseModel):
    """Schema for redeem response."""
    success: bool
    message: str
    reward_name: str
    points_remaining: int
