# backend_lite/app/main.py
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.db import init_db
from fastapi import APIRouter
from app.api.routes import auth, users, profile, transactions, planner, gamification, chat
from app.core.config import settings

router = APIRouter()


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Khi app khoi dong -> Tao bang
    print("Creating tables...")
    init_db()
    yield
    # Khi app tat -> Lam gi do (neu can)

app = FastAPI(title="Filanner Lite", lifespan=lifespan)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(users, prefix=f"{settings.API_STR}/users", tags=["Users"])
app.include_router(auth, prefix=f"{settings.API_STR}/auth", tags=["Authentication"])
app.include_router(profile, prefix=f"{settings.API_STR}/profile", tags=["Profile"])
app.include_router(transactions, prefix=f"{settings.API_STR}/transactions", tags=["Transactions"])
app.include_router(planner, prefix=f"{settings.API_STR}/planner", tags=["Financial Planner"])
app.include_router(gamification, prefix=f"{settings.API_STR}/gamification", tags=["Gamification"])
app.include_router(chat, prefix=f"{settings.API_STR}/chat", tags=["AI Advisor"])

@app.get("/health", include_in_schema=False)
def health_check():
    return {"status": "ok"}

@app.get("/")
def read_root():
    return {"message": "Hello Binh, DB Connected!"}
