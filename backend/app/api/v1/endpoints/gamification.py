from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

from app.api.deps import get_db, get_current_user
from app.models.users import User
from app.schemas.gamification import (
    CheckInResponse,
    RewardResponse,
    RedeemRequest,
    RedeemResponse
)
from app.crud.check_ins import get_or_create_today_check_in
from app.crud.rewards import get_all_rewards, get_reward_by_id, create_user_reward
from app.crud.users import update_user_points
from app.utils.gamification import get_asset_url_for_day, calculate_check_in_points
from app.core.config import settings

router = APIRouter()


@router.post("/check-in", response_model=CheckInResponse)
async def daily_check_in(
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    """
    Daily check-in for gamification.
    Returns streak, 3D asset URL, and points added.
    """
    check_in, is_new = await get_or_create_today_check_in(session, current_user.id)
    
    if not is_new:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Already checked in today"
        )
    
    # Calculate points
    points_added = calculate_check_in_points(check_in.streak_count)
    
    # Update user points
    await update_user_points(session, current_user.id, points_added)
    
    # Get 3D asset URL based on streak day
    asset_url = get_asset_url_for_day(check_in.streak_count)
    
    return CheckInResponse(
        streak=check_in.streak_count,
        asset_url=asset_url,
        points_added=points_added,
        check_in_date=check_in.check_in_date
    )


@router.get("/rewards", response_model=List[RewardResponse])
async def list_rewards(session: AsyncSession = Depends(get_db)):
    """Get list of available rewards."""
    rewards = await get_all_rewards(session)
    return rewards


@router.post("/redeem", response_model=RedeemResponse)
async def redeem_reward(
    redeem_data: RedeemRequest,
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    """Redeem points for a reward."""
    # Get reward
    reward = await get_reward_by_id(session, redeem_data.reward_id)
    
    if not reward:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reward not found"
        )
    
    # Check if user has enough points
    if current_user.total_points < reward.cost_point:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Not enough points"
        )
    
    # Deduct points
    await update_user_points(session, current_user.id, -reward.cost_point)
    
    # Create user reward record
    await create_user_reward(session, current_user.id, reward.id)
    
    return RedeemResponse(
        success=True,
        message=f"Successfully redeemed {reward.name}",
        reward_name=reward.name,
        points_remaining=current_user.total_points - reward.cost_point
    )
