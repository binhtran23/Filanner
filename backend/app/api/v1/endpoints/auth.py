from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db
from app.schemas.auth import UserCreate, UserLogin, Token, UserResponse
from app.crud.users import (
    get_user_by_username,
    get_user_by_email,
    create_user,
)
from app.core.security import verify_password, create_access_token
from app.crud.profiles import create_or_update_profile
from app.crud.transactions import create_transaction
from app.models.transactions import TransactionType, TransactionCategory

router = APIRouter()


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(
    user_data: UserCreate,
    session: AsyncSession = Depends(get_db)
):
    """Register a new user."""
    # Check if username exists
    existing_user = await get_user_by_username(session, user_data.username)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already registered"
        )
    
    # Check if email exists
    existing_email = await get_user_by_email(session, user_data.email)
    if existing_email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create user
    user = await create_user(
        session,
        username=user_data.username,
        email=user_data.email,
        password=user_data.password
    )
    
    return user


@router.post("/login", response_model=Token)
async def login(
    user_data: UserLogin,
    session: AsyncSession = Depends(get_db)
):
    """Login and get access token."""
    # Get user
    user = await get_user_by_username(session, user_data.username)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Verify password
    if not verify_password(user_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Create access token
    access_token = create_access_token(user.id)
    
    return {"access_token": access_token, "token_type": "bearer"}


@router.post("/seed-test-user", response_model=dict)
async def seed_test_user(session: AsyncSession = Depends(get_db)):
    """
    Hackathon utility: Create test user with sample data.
    Username: tayroi / Password: 120anglyen
    """
    username = "tayroi"
    password = "120anglyen"
    email = "tayroi@example.com"
    
    # Check if user exists
    existing = await get_user_by_username(session, username)
    if existing:
        # Return existing user's token
        access_token = create_access_token(existing.id)
        return {
            "message": "Test user already exists",
            "access_token": access_token,
            "username": username
        }
    
    # Create user
    user = await create_user(session, username, email, password)
    
    # Create profile
    await create_or_update_profile(
        session,
        user_id=user.id,
        age=25,
        job="Software Engineer",
        current_salary=30000000,  # 30M VND
        fixed_costs={
            "rent": 5000000,
            "food": 3000000,
            "transport": 1000000,
            "utilities": 500000
        },
        financial_goals={
            "buy_house": 2030,
            "buy_car": 2027
        }
    )
    
    # Create sample transactions
    from datetime import datetime, timedelta
    
    # Income
    await create_transaction(
        session,
        user_id=user.id,
        amount=30000000,
        category=TransactionCategory.INCOME.value,
        type=TransactionType.INCOME.value,
        transaction_date=datetime.utcnow() - timedelta(days=30),
        description="Salary"
    )
    
    # Expenses
    expenses = [
        (5000000, TransactionCategory.BILLS.value, "Rent"),
        (2500000, TransactionCategory.FOOD.value, "Groceries"),
        (800000, TransactionCategory.TRANSPORT.value, "Gas"),
        (1200000, TransactionCategory.ENTERTAINMENT.value, "Movie night"),
    ]
    
    for amount, category, desc in expenses:
        await create_transaction(
            session,
            user_id=user.id,
            amount=amount,
            category=category,
            type=TransactionType.EXPENSE.value,
            transaction_date=datetime.utcnow() - timedelta(days=25),
            description=desc
        )
    
    # Create access token
    access_token = create_access_token(user.id)
    
    return {
        "message": "Test user created successfully",
        "access_token": access_token,
        "username": username,
        "password": password
    }
