from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from datetime import datetime, timedelta

from sqlmodel import Session, select
from app.api.deps import get_db, get_current_user
from app.models.users import User
from app.models.rewards import CheckInResponse, RewardResponse, RedeemRequest, RedeemResponse, Reward, UserReward, DailyCheckIn
from app.utils.gamification import get_asset_url_for_day, calculate_check_in_points

router = APIRouter()


@router.post("/check-in", response_model=CheckInResponse)
def daily_check_in(
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db)
):
    today = datetime.utcnow().date()
    existing = session.exec(
        select(DailyCheckIn)
        .where(DailyCheckIn.user_id == current_user.id)
        .where(DailyCheckIn.check_in_date == today)
    ).first()

    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Already checked in today"
        )

    latest = session.exec(
        select(DailyCheckIn)
        .where(DailyCheckIn.user_id == current_user.id)
        .order_by(DailyCheckIn.check_in_date.desc())
        .limit(1)
    ).first()

    streak_count = 1
    if latest:
        yesterday = today - timedelta(days=1)
        if latest.check_in_date == yesterday:
            streak_count = latest.streak_count + 1

    check_in = DailyCheckIn(
        user_id=current_user.id,
        check_in_date=today,
        streak_count=streak_count
    )
    session.add(check_in)
    session.commit()
    session.refresh(check_in)

    points_added = calculate_check_in_points(check_in.streak_count)
    current_user.total_points += points_added
    session.add(current_user)
    session.commit()
    session.refresh(current_user)

    asset_url = get_asset_url_for_day(check_in.streak_count)

    return CheckInResponse(
        streak=check_in.streak_count,
        asset_url=asset_url,
        points_added=points_added,
        check_in_date=check_in.check_in_date
    )


@router.get("/rewards", response_model=List[RewardResponse])
def list_rewards(session: Session = Depends(get_db)):
    return session.exec(select(Reward)).all()


@router.post("/redeem", response_model=RedeemResponse)
def redeem_reward(
    redeem_data: RedeemRequest,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db)
):
    reward = session.exec(select(Reward).where(Reward.id == redeem_data.reward_id)).first()

    if not reward:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reward not found"
        )

    if current_user.total_points < reward.cost_point:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Not enough points"
        )

    current_user.total_points -= reward.cost_point
    session.add(current_user)
    session.commit()
    session.refresh(current_user)

    user_reward = UserReward(user_id=current_user.id, reward_id=reward.id)
    session.add(user_reward)
    session.commit()
    session.refresh(user_reward)

    return RedeemResponse(
        success=True,
        message=f"Successfully redeemed {reward.name}",
        reward_name=reward.name,
        points_remaining=current_user.total_points
    )
