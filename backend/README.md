# Filanner Backend - FastAPI + SQLModel + PostgreSQL

Backend API cho ứng dụng quản lý tài chính Filanner, được xây dựng cho hackathon.

## 🏗️ Kiến trúc

```
backend/
├── app/
│   ├── api/
│   │   ├── deps.py              # Dependencies (get_db, get_current_user)
│   │   └── v1/
│   │       └── endpoints/       # API routes
│   │           ├── auth.py      # /auth (register, login, seed-test-user)
│   │           ├── users.py     # /users (me, profile)
│   │           ├── transactions.py  # /transactions (CRUD, summary)
│   │           ├── planner.py   # /planner (init, regenerate, nodes)
│   │           ├── gamification.py  # /gamification (check-in, rewards)
│   │           └── chat.py      # /chat (AI advisor)
│   ├── core/
│   │   ├── config.py            # Settings (pydantic-settings)
│   │   └── security.py          # JWT, password hashing
│   ├── crud/                    # CRUD operations
│   ├── db/
│   │   ├── session.py           # Async database session
│   │   └── init_db.py           # Database initialization
│   ├── models/                  # SQLModel models (8 tables)
│   ├── schemas/                 # Pydantic schemas
│   ├── utils/                   # Business logic
│   │   ├── planner_logic.py    # Plan generation logic
│   │   ├── gamification.py     # Points, streaks, assets
│   │   └── ai_chat.py          # AI response generation
│   └── main.py                  # FastAPI app
├── Dockerfile
└── requirements.txt
```

## 🗄️ Database Schema

8 bảng với UUID primary keys:
- **Users**: Authentication + points
- **Profiles**: Financial info (salary, fixed_costs, goals)
- **Transactions**: Income/Expense tracking
- **FinancialPlans**: User's financial plans
- **PlanNodes**: Tree-structured plan steps
- **DailyCheckIns**: Gamification check-ins
- **Rewards**: Available rewards
- **UserRewards**: Claimed rewards

## 🚀 Quick Start

### 1. Cài đặt dependencies

```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# hoặc .venv\Scripts\activate  # Windows
pip install -r requirements.txt
```

### 2. Chạy với Docker

```bash
# Từ root folder
docker-compose up --build
```

Backend sẽ chạy tại: `http://localhost:8000`

### 3. Khởi tạo database (nếu chạy local)

```bash
python -m app.db.init_db
```

### 4. Chạy development server

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## 📚 API Documentation

Sau khi chạy server, truy cập:
- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

## 🔑 API Endpoints

### Authentication (`/api/v1/auth`)
- `POST /auth/register` - Đăng ký
- `POST /auth/login` - Đăng nhập (trả về JWT token)
- `POST /auth/seed-test-user` - Tạo user test (tayroi/120anglyen)

### Users (`/api/v1/users`)
- `GET /users/me` - Thông tin user hiện tại
- `POST /users/profile` - Tạo/cập nhật profile
- `GET /users/profile` - Lấy profile

### Transactions (`/api/v1/transactions`)
- `POST /transactions` - Tạo giao dịch
- `GET /transactions` - Danh sách giao dịch (có filter)
- `GET /transactions/summary` - Tổng hợp thu chi

### Planner (`/api/v1/planner`)
- `POST /planner/init` - Tạo plan dựa trên profile
- `GET /planner/{plan_id}` - Lấy plan và nodes
- `GET /planner` - Danh sách plans
- `PATCH /planner/nodes/{node_id}` - Cập nhật node
- `POST /planner/regenerate` - Tính lại plan theo transactions

### Gamification (`/api/v1/gamification`)
- `POST /gamification/check-in` - Điểm danh
- `GET /gamification/rewards` - Danh sách quà
- `POST /gamification/redeem` - Đổi điểm

### Chat (`/api/v1/chat`)
- `POST /chat/message` - Gửi tin nhắn cho AI advisor

## 🧪 Testing với Test User

Sử dụng endpoint seed để tạo user test:

```bash
curl -X POST http://localhost:8000/api/v1/auth/seed-test-user
```

Response:
```json
{
  "message": "Test user created successfully",
  "access_token": "eyJ...",
  "username": "tayroi",
  "password": "120anglyen"
}
```

Dùng `access_token` cho các request tiếp theo:
```bash
curl -H "Authorization: Bearer eyJ..." http://localhost:8000/api/v1/users/me
```

## 🔧 Environment Variables

File `.env` trong root folder:

```env
# Database
POSTGRES_SERVER=db
POSTGRES_USER=filanner_user
POSTGRES_PASSWORD=filanner_password_2026
POSTGRES_DB=filanner_db

# Security
SECRET_KEY=your-super-secret-key-change-this
ACCESS_TOKEN_EXPIRE_MINUTES=10080

# App
PROJECT_NAME=Filanner API
BACKEND_CORS_ORIGINS=["*"]
```

## 💡 Business Logic

### Planner Logic (`utils/planner_logic.py`)
- Tính toán: `Lương - Chi phí cố định = Khả năng tiết kiệm`
- Tạo 12 nodes tiết kiệm hàng tháng (70% savings capacity)
- Link nodes theo chuỗi (parent_node_id)
- Thêm milestone cuối năm

### Gamification (`utils/gamification.py`)
- Base points: 10 points/check-in
- Streak bonus: 5 points/5 days
- 3D asset URLs theo ngày (day-1.glb, day-2.glb...)

### AI Chat (`utils/ai_chat.py`)
- Rule-based responses (cho demo)
- Phát hiện: overspending, saving, planning keywords
- Trả về advice + action suggestions

## 📦 Dependencies

- **FastAPI** ≥0.110 - Web framework
- **SQLModel** ≥0.0.16 - ORM (SQLAlchemy + Pydantic)
- **asyncpg** ≥0.29 - Async PostgreSQL driver
- **python-jose** - JWT tokens
- **passlib** - Password hashing
- **pydantic-settings** - Settings management

## 🐳 Docker

**Backend service**:
- Multi-stage build (builder + production)
- Non-root user (appuser)
- Auto init database on startup
- Hot reload trong development mode

**Database service**:
- PostgreSQL với pgvector extension
- Health checks
- Volume mount: `./mnt/db`

## 🛠️ Development Tips

### 1. Thêm endpoint mới
```python
# backend/app/api/v1/endpoints/new_feature.py
from fastapi import APIRouter
router = APIRouter()

@router.get("/")
async def new_feature():
    return {"message": "New feature"}

# Thêm vào main.py
app.include_router(new_feature.router, prefix="/api/v1/new", tags=["New"])
```

### 2. Thêm model mới
```python
# backend/app/models/new_model.py
from sqlmodel import SQLModel, Field
from uuid import UUID, uuid4

class NewModel(SQLModel, table=True):
    __tablename__ = "new_models"
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    # ... fields

# Import trong init_db.py để tạo table
```

### 3. Debug database
```bash
docker exec -it filanner_db psql -U filanner_user -d filanner_db
\dt  # List tables
SELECT * FROM users;
```

## 📝 TODO (Post-Hackathon)

- [ ] Add Alembic migrations
- [ ] Integrate real AI service (LangGraph/OpenAI)
- [ ] Add comprehensive tests (pytest)
- [ ] Rate limiting
- [ ] Request logging
- [ ] Error tracking (Sentry)
- [ ] API versioning strategy
- [ ] Background tasks (Celery/Dramatiq)

## 🏆 Hackathon Features

✅ **Seed test user** - 1-click demo setup
✅ **Auto planner** - Tạo plan từ profile
✅ **Gamification** - Streaks, points, rewards
✅ **AI advisor** - Rule-based tư vấn
✅ **Transaction summary** - Chart data
✅ **Health checks** - `/health` endpoint
✅ **Auto CORS** - Mobile app friendly

## 📄 License

MIT License - Hackathon Project 2026
