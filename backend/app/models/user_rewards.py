from sqlmodel import SQLModel, Field
from uuid import UUID, uuid4
from datetime import datetime


class UserReward(SQLModel, table=True):
    """User's claimed rewards."""
    
    __tablename__ = "user_rewards"
    
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: UUID = Field(foreign_key="users.id", index=True)
    reward_id: UUID = Field(foreign_key="rewards.id", index=True)
    claimed_at: datetime = Field(default_factory=datetime.utcnow)
