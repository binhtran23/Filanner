from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from uuid import UUID
from typing import Optional
from app.models.users import User
from app.core.security import get_password_hash


async def get_user_by_username(session: AsyncSession, username: str) -> Optional[User]:
    """Get user by username."""
    result = await session.execute(select(User).where(User.username == username))
    return result.scalar_one_or_none()


async def get_user_by_email(session: AsyncSession, email: str) -> Optional[User]:
    """Get user by email."""
    result = await session.execute(select(User).where(User.email == email))
    return result.scalar_one_or_none()


async def get_user_by_id(session: AsyncSession, user_id: UUID) -> Optional[User]:
    """Get user by ID."""
    result = await session.execute(select(User).where(User.id == user_id))
    return result.scalar_one_or_none()


async def create_user(
    session: AsyncSession, 
    username: str, 
    email: str, 
    password: str
) -> User:
    """Create a new user."""
    hashed_password = get_password_hash(password)
    user = User(
        username=username,
        email=email,
        hashed_password=hashed_password
    )
    session.add(user)
    await session.commit()
    await session.refresh(user)
    return user


async def update_user_points(
    session: AsyncSession, 
    user_id: UUID, 
    points_change: int
) -> Optional[User]:
    """Update user's total points."""
    user = await get_user_by_id(session, user_id)
    if user:
        user.total_points += points_change
        session.add(user)
        await session.commit()
        await session.refresh(user)
    return user
