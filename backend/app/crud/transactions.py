from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_
from uuid import UUID
from datetime import datetime
from typing import List, Optional
from app.models.transactions import Transaction


async def create_transaction(
    session: AsyncSession,
    user_id: UUID,
    amount: float,
    category: str,
    type: str,
    transaction_date: Optional[datetime] = None,
    description: Optional[str] = None
) -> Transaction:
    """Create a new transaction."""
    transaction = Transaction(
        user_id=user_id,
        amount=amount,
        category=category,
        type=type,
        transaction_date=transaction_date or datetime.utcnow(),
        description=description
    )
    session.add(transaction)
    await session.commit()
    await session.refresh(transaction)
    return transaction


async def get_transactions_by_user(
    session: AsyncSession,
    user_id: UUID,
    skip: int = 0,
    limit: int = 100,
    category: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None
) -> List[Transaction]:
    """Get transactions for a user with optional filters."""
    query = select(Transaction).where(Transaction.user_id == user_id)
    
    if category:
        query = query.where(Transaction.category == category)
    if start_date:
        query = query.where(Transaction.transaction_date >= start_date)
    if end_date:
        query = query.where(Transaction.transaction_date <= end_date)
    
    query = query.order_by(Transaction.transaction_date.desc())
    query = query.offset(skip).limit(limit)
    
    result = await session.execute(query)
    return list(result.scalars().all())


async def get_transaction_summary(
    session: AsyncSession,
    user_id: UUID,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None
) -> dict:
    """Get transaction summary for a user."""
    # Build base query
    query = select(Transaction).where(Transaction.user_id == user_id)
    
    if start_date:
        query = query.where(Transaction.transaction_date >= start_date)
    if end_date:
        query = query.where(Transaction.transaction_date <= end_date)
    
    result = await session.execute(query)
    transactions = result.scalars().all()
    
    # Calculate summary
    total_income = sum(t.amount for t in transactions if t.type == "INCOME")
    total_expense = sum(t.amount for t in transactions if t.type == "EXPENSE")
    
    # Group by category
    by_category = {}
    for t in transactions:
        if t.category not in by_category:
            by_category[t.category] = 0
        by_category[t.category] += t.amount
    
    return {
        "total_income": total_income,
        "total_expense": total_expense,
        "net_amount": total_income - total_expense,
        "by_category": by_category
    }
