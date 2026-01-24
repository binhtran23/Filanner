from app.api.routes.auth import router as auth
from app.api.routes.users import router as users
from app.api.routes.profile import router as profile
from app.api.routes.transactions import router as transactions
from app.api.routes.planner import router as planner
from app.api.routes.gamification import router as gamification
from app.api.routes.chat import router as chat

__all__ = [
    "auth",
    "users",
    "profile",
    "transactions",
    "planner",
    "gamification",
    "chat",
]
