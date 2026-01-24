from fastapi import APIRouter, Depends, Query
from datetime import datetime
from typing import Optional, List

from sqlmodel import Session
from app.api.deps import get_db, get_current_user
from app.models.users import User
from app.models.transactions import TransactionCreate, TransactionResponse, TransactionSummary
from sqlmodel import select
from app.models.transactions import Transaction

router = APIRouter()


@router.post("", response_model=TransactionResponse, status_code=201)
def create_new_transaction(
    transaction_data: TransactionCreate,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db)
):
    transaction = Transaction(
        user_id=current_user.id,
        amount=transaction_data.amount,
        category=transaction_data.category,
        type=transaction_data.type,
        transaction_date=transaction_data.transaction_date,
        description=transaction_data.description
    )
    session.add(transaction)
    session.commit()
    session.refresh(transaction)
    return transaction


@router.get("", response_model=List[TransactionResponse])
def get_transactions(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    category: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db)
):
    statement = select(Transaction).where(Transaction.user_id == current_user.id)

    if category:
        statement = statement.where(Transaction.category == category)
    if start_date:
        statement = statement.where(Transaction.transaction_date >= start_date)
    if end_date:
        statement = statement.where(Transaction.transaction_date <= end_date)

    statement = statement.order_by(Transaction.transaction_date.desc())
    statement = statement.offset(skip).limit(limit)

    return session.exec(statement).all()


@router.get("/summary", response_model=TransactionSummary)
def get_summary(
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db)
):
    statement = select(Transaction).where(Transaction.user_id == current_user.id)

    if start_date:
        statement = statement.where(Transaction.transaction_date >= start_date)
    if end_date:
        statement = statement.where(Transaction.transaction_date <= end_date)

    transactions = session.exec(statement).all()

    total_income = sum(t.amount for t in transactions if t.type == "INCOME")
    total_expense = sum(t.amount for t in transactions if t.type == "EXPENSE")

    by_category = {}
    for transaction in transactions:
        by_category[transaction.category] = by_category.get(transaction.category, 0) + transaction.amount

    return {
        "total_income": total_income,
        "total_expense": total_expense,
        "net_amount": total_income - total_expense,
        "by_category": by_category
    }
