from datetime import datetime
from typing import Optional
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select

from app.api.deps import get_current_user
from app.db import get_session
from app.models.users import (
    User,
    Profile,
    ProfileCreate,
    ProfileUpdate,
    ProfileResponse,
    FixedExpense,
    FixedExpenseCreate,
    FixedExpenseUpdate,
)

router = APIRouter()


def _get_profile(session: Session, user_id) -> Optional[Profile]:
    return session.exec(select(Profile).where(Profile.user_id == user_id)).first()


def _normalize_fixed_expenses(expenses: Optional[list[FixedExpenseCreate]]) -> list[dict]:
    if not expenses:
        return []

    normalized = []
    for expense in expenses:
        payload = expense.model_dump()
        payload["id"] = payload.get("id") or str(uuid4())
        normalized.append(payload)
    return normalized


@router.get("", response_model=ProfileResponse)
def get_profile(
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
):
    profile = _get_profile(session, current_user.id)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found",
        )
    return profile


@router.post("", response_model=ProfileResponse)
def create_profile(
    profile_data: ProfileCreate,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
):
    profile = _get_profile(session, current_user.id)
    fixed_expenses = _normalize_fixed_expenses(profile_data.fixed_expenses)

    if profile:
        profile.age = profile_data.age
        profile.gender = profile_data.gender
        profile.occupation = profile_data.occupation
        profile.education_level = profile_data.education_level
        profile.dependents = profile_data.dependents
        profile.monthly_income = profile_data.monthly_income
        profile.other_income = profile_data.other_income
        profile.current_savings = profile_data.current_savings
        profile.current_debt = profile_data.current_debt
        profile.fixed_expenses = fixed_expenses
        profile.goals = profile_data.goals
        profile.risk_tolerance = profile_data.risk_tolerance
        profile.updated_at = datetime.utcnow()
    else:
        profile = Profile(
            user_id=current_user.id,
            age=profile_data.age,
            gender=profile_data.gender,
            occupation=profile_data.occupation,
            education_level=profile_data.education_level,
            dependents=profile_data.dependents,
            monthly_income=profile_data.monthly_income,
            other_income=profile_data.other_income,
            current_savings=profile_data.current_savings,
            current_debt=profile_data.current_debt,
            fixed_expenses=fixed_expenses,
            goals=profile_data.goals,
            risk_tolerance=profile_data.risk_tolerance,
        )

    session.add(profile)
    session.commit()
    session.refresh(profile)
    return profile


@router.put("", response_model=ProfileResponse)
def update_profile(
    profile_data: ProfileUpdate,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
):
    profile = _get_profile(session, current_user.id)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found",
        )

    if profile_data.age is not None:
        profile.age = profile_data.age
    if profile_data.gender is not None:
        profile.gender = profile_data.gender
    if profile_data.occupation is not None:
        profile.occupation = profile_data.occupation
    if profile_data.education_level is not None:
        profile.education_level = profile_data.education_level
    if profile_data.dependents is not None:
        profile.dependents = profile_data.dependents
    if profile_data.monthly_income is not None:
        profile.monthly_income = profile_data.monthly_income
    if profile_data.other_income is not None:
        profile.other_income = profile_data.other_income
    if profile_data.current_savings is not None:
        profile.current_savings = profile_data.current_savings
    if profile_data.current_debt is not None:
        profile.current_debt = profile_data.current_debt
    if profile_data.fixed_expenses is not None:
        profile.fixed_expenses = _normalize_fixed_expenses(profile_data.fixed_expenses)
    if profile_data.goals is not None:
        profile.goals = profile_data.goals
    if profile_data.risk_tolerance is not None:
        profile.risk_tolerance = profile_data.risk_tolerance
    profile.updated_at = datetime.utcnow()

    session.add(profile)
    session.commit()
    session.refresh(profile)
    return profile


@router.get("/fixed-expenses", response_model=list[FixedExpense])
def list_fixed_expenses(
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
):
    profile = _get_profile(session, current_user.id)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found",
        )
    return profile.fixed_expenses or []


@router.post("/fixed-expenses", response_model=FixedExpense)
def add_fixed_expense(
    expense_data: FixedExpenseCreate,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
):
    profile = _get_profile(session, current_user.id)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found",
        )

    expense = FixedExpense(
        id=str(uuid4()),
        name=expense_data.name,
        category=expense_data.category,
        amount=expense_data.amount,
        description=expense_data.description,
    )

    expenses = list(profile.fixed_expenses or [])
    expenses.append(expense.model_dump())
    profile.fixed_expenses = expenses
    profile.updated_at = datetime.utcnow()

    session.add(profile)
    session.commit()
    session.refresh(profile)
    return expense


@router.put("/fixed-expenses/{expense_id}", response_model=FixedExpense)
def update_fixed_expense(
    expense_id: str,
    expense_data: FixedExpenseUpdate,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
):
    profile = _get_profile(session, current_user.id)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found",
        )

    expenses = list(profile.fixed_expenses or [])
    for expense in expenses:
        if expense.get("id") == expense_id:
            if expense_data.name is not None:
                expense["name"] = expense_data.name
            if expense_data.category is not None:
                expense["category"] = expense_data.category
            if expense_data.amount is not None:
                expense["amount"] = expense_data.amount
            if expense_data.description is not None:
                expense["description"] = expense_data.description

            profile.fixed_expenses = expenses
            profile.updated_at = datetime.utcnow()
            session.add(profile)
            session.commit()
            session.refresh(profile)
            return FixedExpense(**expense)

    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail="Fixed expense not found",
    )


@router.delete("/fixed-expenses/{expense_id}", response_model=dict)
def delete_fixed_expense(
    expense_id: str,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
):
    profile = _get_profile(session, current_user.id)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found",
        )

    expenses = list(profile.fixed_expenses or [])
    new_expenses = [expense for expense in expenses if expense.get("id") != expense_id]
    if len(new_expenses) == len(expenses):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Fixed expense not found",
        )

    profile.fixed_expenses = new_expenses
    profile.updated_at = datetime.utcnow()
    session.add(profile)
    session.commit()
    return {"detail": "Fixed expense deleted"}
