from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from uuid import UUID
from datetime import date, timedelta
from typing import Optional
from app.models.daily_check_ins import DailyCheckIn


async def get_latest_check_in(
    session: AsyncSession,
    user_id: UUID
) -> Optional[DailyCheckIn]:
    """Get the latest check-in for a user."""
    result = await session.execute(
        select(DailyCheckIn)
        .where(DailyCheckIn.user_id == user_id)
        .order_by(DailyCheckIn.check_in_date.desc())
        .limit(1)
    )
    return result.scalar_one_or_none()


async def create_check_in(
    session: AsyncSession,
    user_id: UUID,
    check_in_date: date,
    streak_count: int
) -> DailyCheckIn:
    """Create a new check-in."""
    check_in = DailyCheckIn(
        user_id=user_id,
        check_in_date=check_in_date,
        streak_count=streak_count
    )
    session.add(check_in)
    await session.commit()
    await session.refresh(check_in)
    return check_in


async def get_or_create_today_check_in(
    session: AsyncSession,
    user_id: UUID
) -> tuple[DailyCheckIn, bool]:
    """
    Get or create today's check-in.
    Returns (check_in, is_new) tuple.
    """
    today = date.today()
    
    # Check if already checked in today
    result = await session.execute(
        select(DailyCheckIn)
        .where(DailyCheckIn.user_id == user_id)
        .where(DailyCheckIn.check_in_date == today)
    )
    existing = result.scalar_one_or_none()
    
    if existing:
        return existing, False
    
    # Get latest check-in to calculate streak
    latest = await get_latest_check_in(session, user_id)
    
    if latest:
        yesterday = today - timedelta(days=1)
        if latest.check_in_date == yesterday:
            # Continue streak
            streak_count = latest.streak_count + 1
        else:
            # Streak broken, start over
            streak_count = 1
    else:
        # First check-in
        streak_count = 1
    
    # Create new check-in
    check_in = await create_check_in(session, user_id, today, streak_count)
    return check_in, True
