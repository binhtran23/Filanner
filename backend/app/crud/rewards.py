from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from uuid import UUID
from typing import List, Optional
from app.models.rewards import Reward
from app.models.user_rewards import UserReward


async def get_all_rewards(session: AsyncSession) -> List[Reward]:
    """Get all available rewards."""
    result = await session.execute(select(Reward))
    return list(result.scalars().all())


async def get_reward_by_id(
    session: AsyncSession,
    reward_id: UUID
) -> Optional[Reward]:
    """Get reward by ID."""
    result = await session.execute(
        select(Reward).where(Reward.id == reward_id)
    )
    return result.scalar_one_or_none()


async def create_user_reward(
    session: AsyncSession,
    user_id: UUID,
    reward_id: UUID
) -> UserReward:
    """Create a user reward (claim a reward)."""
    user_reward = UserReward(user_id=user_id, reward_id=reward_id)
    session.add(user_reward)
    await session.commit()
    await session.refresh(user_reward)
    return user_reward


async def get_user_rewards(
    session: AsyncSession,
    user_id: UUID
) -> List[UserReward]:
    """Get all rewards claimed by a user."""
    result = await session.execute(
        select(UserReward)
        .where(UserReward.user_id == user_id)
        .order_by(UserReward.claimed_at.desc())
    )
    return list(result.scalars().all())
