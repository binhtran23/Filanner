from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from app.db import get_session
from app.models.users import User, Profile
from app.models.auth import UserCreate, UserResponse
from app.core.security import get_password_hash

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

# 1. API Tao User moi (POST /users)
@router.post("/", response_model=UserResponse)
def create_user(user_in: UserCreate, session: Session = Depends(get_session)):
    # Check for duplicate email
    existing_user = session.exec(select(User).where(User.email == user_in.email)).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email da ton tai")
    
    # Check for duplicate username
    existing_username = session.exec(select(User).where(User.username == user_in.username)).first()
    if existing_username:
        raise HTTPException(status_code=400, detail="Username da ton tai")
    
    hashed_password = get_password_hash(user_in.password)
    db_user = User.model_validate(
        user_in, 
        update={"hashed_password": hashed_password} # Map password -> hashed_password
    )
    
    session.add(db_user)
    session.commit()
    session.refresh(db_user)
    _ensure_default_profile(session, db_user.id)
    return db_user

# 2. API Lay danh sach User (GET /users)
@router.get("/", response_model=list[UserResponse])
def read_users(session: Session = Depends(get_session)):
    return session.exec(select(User)).all()

# 3. API Lay thong tin User theo UUID (GET /users/{user_id})
@router.get("/{user_id}", response_model=UserResponse)
def read_user(user_id: UUID, session: Session = Depends(get_session)):
    user = session.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User khong ton tai")
    return user

# 4. API Xoa User theo UUID (DELETE /users/{user_id})
@router.delete("/{user_id}", response_model=dict)
def delete_user(user_id: UUID, session: Session = Depends(get_session)):
    user = session.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User khong ton tai")
    session.delete(user)
    session.commit()
    return {"detail": "User da duoc xoa"}

# 5. API Cap nhat thong tin User theo UUID (PUT /users/{user_id})
@router.patch("/{user_id}", response_model=UserResponse)
def update_user(user_id: UUID, user_in: UserCreate, session: Session = Depends(get_session)):
    user = session.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User khong ton tai")

    user.username = user_in.username
    user.email = user_in.email
    user.hashed_password = get_password_hash(user_in.password)

    session.add(user)
    session.commit()
    session.refresh(user)
    return user
