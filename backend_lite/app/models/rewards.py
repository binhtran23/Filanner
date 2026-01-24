from sqlmodel import SQLModel, Field
from pydantic import BaseModel
from uuid import UUID, uuid4
from datetime import date, datetime
from typing import Optional


class Reward(SQLModel, table=True):
    """Reward items for gamification."""

    __tablename__ = "rewards"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    name: str = Field(max_length=255)  # "Kho ga", "Gau bong"
    cost_point: int = Field(ge=0)
    image_url: Optional[str] = Field(default=None, max_length=500)
    description: Optional[str] = Field(default=None, max_length=1000)


class DailyCheckIn(SQLModel, table=True):
    """Daily check-in model for gamification."""

    __tablename__ = "daily_check_ins"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: UUID = Field(foreign_key="users.id", index=True)
    check_in_date: date = Field(index=True)
    streak_count: int = Field(default=1, ge=0)


class UserReward(SQLModel, table=True):
    """User's claimed rewards."""

    __tablename__ = "user_rewards"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: UUID = Field(foreign_key="users.id", index=True)
    reward_id: UUID = Field(foreign_key="rewards.id", index=True)
    claimed_at: datetime = Field(default_factory=datetime.utcnow)


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
