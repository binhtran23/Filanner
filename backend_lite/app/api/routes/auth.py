from datetime import timedelta
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlmodel import Session, select

# Import cac module noi bo
from app.db import get_session
from app.core.security import verify_password, create_access_token_legacy, get_password_hash
from app.core.config import settings
from app.models.users import User
from app.models.auth import Token, UserCreate, UserResponse

router = APIRouter()

@router.post("/login", response_model=Token)
def login_access_token(
    session: Annotated[Session, Depends(get_session)],
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()]
):
    """
    OAuth2 compatible token login, get an access token for future requests.
    - form_data.username: Client gui username vao truong nay.
    - form_data.password: Password tho.
    """
    user = session.exec(select(User).where(User.username == form_data.username)).first()

    # 2. Kiem tra User ton tai va Password dung
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Username hoac mat khau khong chinh xac",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # 3. Tao token
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token_legacy(
        subject=user.id, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer"
    }

# --------------------------------------------------------------------------
# 2. API DANG KY (Register)
# URL: POST /api/v1/auth/signup
# --------------------------------------------------------------------------
@router.post("/signup", response_model=UserResponse)
def register_user(
    user_in: UserCreate, 
    session: Annotated[Session, Depends(get_session)]
):
    """
    Create new user without the need to be logged in.
    """
    # 1. Check xem email da ton tai chua
    user = session.exec(select(User).where(User.email == user_in.email)).first()
    if user:
        raise HTTPException(
            status_code=400,
            detail="Email nay da duoc su dung trong he thong",
        )
    
    # 2. Check xem username da ton tai chua (neu can unique username)
    user_by_name = session.exec(select(User).where(User.username == user_in.username)).first()
    if user_by_name:
        raise HTTPException(
            status_code=400,
            detail="Username nay da duoc su dung",
        )

    # 3. Tao User moi (hash password)
    # user_in.password la pass tho, ta can hash no truoc khi luu
    db_user = User.model_validate(
        user_in,
        update={"hashed_password": get_password_hash(user_in.password)}
    )
    
    # Gan cac gia tri mac dinh neu model chua co
    # db_user.total_points = 0 # Neu trong model User chua set default
    
    session.add(db_user)
    session.commit()
    session.refresh(db_user)
    
    return db_user
