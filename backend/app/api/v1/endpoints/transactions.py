from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime
from typing import Optional, List

from app.api.deps import get_db, get_current_user
from app.models.users import User
from app.schemas.transactions import (
    TransactionCreate,
    TransactionResponse,
    TransactionSummary
)
from app.crud.transactions import (
    create_transaction,
    get_transactions_by_user,
    get_transaction_summary
)

router = APIRouter()


@router.post("", response_model=TransactionResponse, status_code=201)
async def create_new_transaction(
    transaction_data: TransactionCreate,
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    """Create a new transaction."""
    transaction = await create_transaction(
        session,
        user_id=current_user.id,
        amount=transaction_data.amount,
        category=transaction_data.category,
        type=transaction_data.type,
        transaction_date=transaction_data.transaction_date,
        description=transaction_data.description
    )
    return transaction


@router.get("", response_model=List[TransactionResponse])
async def get_transactions(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    category: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    """Get transactions with optional filters."""
    transactions = await get_transactions_by_user(
        session,
        user_id=current_user.id,
        skip=skip,
        limit=limit,
        category=category,
        start_date=start_date,
        end_date=end_date
    )
    return transactions


@router.get("/summary", response_model=TransactionSummary)
async def get_summary(
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    """Get transaction summary (for charts)."""
    summary = await get_transaction_summary(
        session,
        user_id=current_user.id,
        start_date=start_date,
        end_date=end_date
    )
    return summary
