from sqlmodel import SQLModel, Field
from uuid import UUID, uuid4
from datetime import date


class DailyCheckIn(SQLModel, table=True):
    """Daily check-in model for gamification."""
    
    __tablename__ = "daily_check_ins"
    
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: UUID = Field(foreign_key="users.id", index=True)
    check_in_date: date = Field(index=True)
    streak_count: int = Field(default=1, ge=0)
