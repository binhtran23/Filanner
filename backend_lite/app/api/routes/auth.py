from datetime import timedelta
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlmodel import Session, select

# Import cac module noi bo
from app.db import get_session
from app.core.security import verify_password, create_access_token_legacy, get_password_hash
from app.core.config import settings
from app.models.users import User, Profile
from app.models.auth import Token, UserCreate, UserResponse

router = APIRouter()


def _ensure_default_profile(session: Session, user_id):
    profile = session.exec(select(Profile).where(Profile.user_id == user_id)).first()
    if profile:
        return profile
    profile = Profile(user_id=user_id)
    session.add(profile)
    session.commit()
    session.refresh(profile)
    return profile

@router.post("/login", response_model=Token)
async def login_access_token_json(
    request: Request,
    session: Annotated[Session, Depends(get_session)]
):
    """
    JSON or form login, get an access token for future requests.
    """
    content_type = request.headers.get("content-type", "")
    data = {}

    if "application/x-www-form-urlencoded" in content_type or "multipart/form-data" in content_type:
        form = await request.form()
        data = dict(form)
    else:
        try:
            data = await request.json()
        except Exception:
            data = {}

    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Username va mat khau la bat buoc",
        )

    user = session.exec(select(User).where(User.username == username)).first()

    if not user or not verify_password(password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Username hoac mat khau khong chinh xac",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token_legacy(
        subject=user.id, expires_delta=access_token_expires
    )

    return {
        "access_token": access_token,
        "token_type": "bearer"
    }


@router.post("/login-form", response_model=Token)
def login_access_token_form(
    session: Annotated[Session, Depends(get_session)],
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()]
):
    """
    OAuth2 compatible token login, get an access token for future requests.
    - form_data.username: Client gui username vao truong nay.
    - form_data.password: Password tho.
    """
    user = session.exec(select(User).where(User.username == form_data.username)).first()

    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Username hoac mat khau khong chinh xac",
            headers={"WWW-Authenticate": "Bearer"},
        )

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

    _ensure_default_profile(session, db_user.id)
    
    return db_user
