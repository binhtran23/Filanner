from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user
from app.models.users import User
from app.schemas.auth import UserResponse
from app.schemas.users import ProfileCreate, ProfileResponse
from app.crud.profiles import get_profile_by_user_id, create_or_update_profile

router = APIRouter()


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    """Get current user information."""
    return current_user


@router.post("/profile", response_model=ProfileResponse)
async def upsert_profile(
    profile_data: ProfileCreate,
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    """Create or update user profile."""
    profile = await create_or_update_profile(
        session,
        user_id=current_user.id,
        age=profile_data.age,
        job=profile_data.job,
        current_salary=profile_data.current_salary,
        fixed_costs=profile_data.fixed_costs,
        financial_goals=profile_data.financial_goals
    )
    return profile


@router.get("/profile", response_model=ProfileResponse)
async def get_profile(
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    """Get user profile."""
    profile = await get_profile_by_user_id(session, current_user.id)
    if not profile:
        from fastapi import HTTPException, status
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found"
        )
    return profile
