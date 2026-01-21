from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from uuid import UUID
from typing import Optional
from app.models.profiles import Profile


async def get_profile_by_user_id(
    session: AsyncSession, 
    user_id: UUID
) -> Optional[Profile]:
    """Get profile by user ID."""
    result = await session.execute(
        select(Profile).where(Profile.user_id == user_id)
    )
    return result.scalar_one_or_none()


async def create_or_update_profile(
    session: AsyncSession,
    user_id: UUID,
    age: Optional[int] = None,
    job: Optional[str] = None,
    current_salary: Optional[float] = None,
    fixed_costs: dict = None,
    financial_goals: dict = None
) -> Profile:
    """Create or update user profile."""
    profile = await get_profile_by_user_id(session, user_id)
    
    if profile:
        # Update existing profile
        if age is not None:
            profile.age = age
        if job is not None:
            profile.job = job
        if current_salary is not None:
            profile.current_salary = current_salary
        if fixed_costs is not None:
            profile.fixed_costs = fixed_costs
        if financial_goals is not None:
            profile.financial_goals = financial_goals
    else:
        # Create new profile
        profile = Profile(
            user_id=user_id,
            age=age,
            job=job,
            current_salary=current_salary,
            fixed_costs=fixed_costs or {},
            financial_goals=financial_goals or {}
        )
    
    session.add(profile)
    await session.commit()
    await session.refresh(profile)
    return profile
