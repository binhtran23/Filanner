# backend_lite/app/db.py
from sqlmodel import SQLModel, create_engine, Session
from app.core.config import settings

# 1. Tao Engine ket noi
# echo=True de khi chay no in cau lenh SQL ra terminal cho ban de debug
engine = create_engine(settings.DATABASE_URL, echo=True)

# 2. Ham khoi tao Database (Tao bang)
def init_db():
    import app.models  # Ensure models are registered
    SQLModel.metadata.create_all(engine)


def recreate_db():
    import app.models  # Ensure models are registered
    SQLModel.metadata.drop_all(engine)
    SQLModel.metadata.create_all(engine)

# 3. Dependency de lay Session (Dung trong API)
def get_session():
    with Session(engine) as session:
        yield session
