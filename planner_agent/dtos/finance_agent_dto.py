# app/dtos/finance_dto.py
from pydantic import BaseModel, Field
from typing import List, Optional
from enum import Enum
from datetime import datetime

# --- ENUM CHO PYTHON (Map với Prisma) ---
class TaskStatus(str, Enum):
    PENDING = "PENDING"
    PROCESSING = "PROCESSING"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"
    NOT_FOUND = "NOT_FOUND"

# --- INPUT MODEL (Request Body) ---
class ChiTieuItem(BaseModel):
    name: str = Field(..., alias="ten_chi_tieu")
    amount: float = Field(..., alias="uoc_tinh")
    frequency: str = Field(..., alias="tan_suat")
    note: Optional[str] = Field(None, alias="note")

class UserProfileRequest(BaseModel):
    # ID từ hệ thống bên ngoài gửi vào (Optional)
    external_user_id: Optional[int] = Field(None, alias="user_id")

    age: int = Field(..., alias="tuoi_tac")
    job: str = Field(..., alias="nghe_nghiep")
    marital_status: str = Field(..., alias="tinh_trang_hon_nhan")
    monthly_income: float = Field(..., alias="thu_nhap_hang_thang")
    
    has_debt: bool = Field(False, alias="no")
    total_debt: Optional[float] = Field(None, alias="tong_no")
    
    mandatory_expenses: List[ChiTieuItem] = Field(..., alias="chi_tieu_bat_buoc")
    incidental_expense_percent: float = Field(0, alias="chi_tieu_phat_sinh")
    goal: Optional[str] = Field(None, alias="muc_tieu")

    class Config:
        populate_by_name = True

# --- OUTPUT MODEL (Response) ---
class TaskResponse(BaseModel):
    """Trả về ngay sau khi gọi POST"""
    task_id: str
    status: TaskStatus
    message: str

class PlanResultResponse(BaseModel):
    """Trả về khi gọi GET polling"""
    task_id: str
    status: TaskStatus
    plan_content: Optional[str] = None
    error_message: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None