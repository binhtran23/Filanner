from sqlmodel import SQLModel, Field
from uuid import UUID, uuid4
from typing import Optional


class Reward(SQLModel, table=True):
    """Reward items for gamification."""
    
    __tablename__ = "rewards"
    
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    name: str = Field(max_length=255)  # "Khô gà", "Gấu bông"
    cost_point: int = Field(ge=0)
    image_url: Optional[str] = Field(default=None, max_length=500)
    description: Optional[str] = Field(default=None, max_length=1000)
