from sqlmodel import Session
from uuid import UUID
from datetime import datetime

from sqlmodel import select
from app.models.chat import ChatResponse
from app.models.users import Profile
from app.models.transactions import Transaction


def generate_ai_response(session: Session, user_id: UUID, message: str) -> ChatResponse:
    message_lower = message.lower()

    profile = session.exec(select(Profile).where(Profile.user_id == user_id)).first()

    now = datetime.utcnow()
    start_of_month = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    statement = select(Transaction).where(Transaction.user_id == user_id)
    statement = statement.where(Transaction.transaction_date >= start_of_month)
    transactions = session.exec(statement).all()

    total_income = sum(t.amount for t in transactions if t.type == "INCOME")
    total_expense = sum(t.amount for t in transactions if t.type == "EXPENSE")
    summary = {
        "total_income": total_income,
        "total_expense": total_expense,
    }

    if any(word in message_lower for word in ["tieu lo", "chi tieu qua", "vuot qua", "lo mua"]):
        total_fixed = sum(profile.fixed_costs.values()) if profile and profile.fixed_costs else 0
        budget_left = profile.current_salary - total_fixed - summary["total_expense"] if profile else 0

        response_text = (
            "Minh hieu roi, dung lo!\n\n"
            "Chi tieu vuot du kien xay ra voi ai cung co. Day la goi y:\n\n"
            "1. Danh gia lai: Xem mon do co that su can thiet khong?\n"
            "2. Cat giam chi tieu khac: Giam chi tieu giai tri hoac an uong ngoai thang nay.\n"
            "3. Tang thu nhap: Can nhac lam them hoac ban do cu.\n\n"
            f"Ngan sach con lai thang nay: {budget_left:,.0f} VND\n\n"
            "Ban van co the can bang duoc!"
        )

        return ChatResponse(
            message=response_text,
            action="SUGGEST_SAVING",
            response_metadata={
                "budget_remaining": budget_left,
                "overspending_detected": True
            }
        )

    if any(word in message_lower for word in ["tiet kiem", "save", "de danh"]):
        if profile and profile.current_salary:
            total_fixed = sum(profile.fixed_costs.values()) if profile.fixed_costs else 0
            savings_capacity = profile.current_salary - total_fixed
            suggested_savings = savings_capacity * 0.3

            response_text = (
                "Tuyet voi khi ban muon tiet kiem!\n\n"
                "Quy tac 50-30-20:\n"
                "- 50% chi tieu thiet yeu\n"
                "- 30% chi tieu ca nhan\n"
                "- 20% tiet kiem/dau tu\n\n"
                f"Voi luong cua ban, minh goi y tiet kiem: {suggested_savings:,.0f} VND/thang\n\n"
                "Do la mot buoc khoi dau tot!"
            )

            return ChatResponse(
                message=response_text,
                action="SUGGEST_SAVING",
                response_metadata={
                    "suggested_amount": suggested_savings,
                    "savings_rule": "50-30-20"
                }
            )

    if any(word in message_lower for word in ["ke hoach", "plan", "lap ngan sach"]):
        response_text = (
            "Tuyet voi! Lap ke hoach tai chinh la buoc dau quan trong.\n\n"
            "Buoc 1: Cap nhat day du thu nhap va chi phi co dinh\n"
            "Buoc 2: Theo doi moi khoan chi tieu hang ngay\n"
            "Buoc 3: Tao muc tieu tai chinh cu the\n"
            "Buoc 4: Dieu chinh khi can thiet\n\n"
            "Bat dau tu viec nho nhat nhe!"
        )

        return ChatResponse(
            message=response_text,
            action="CREATE_PLAN",
            response_metadata={"suggestion": "start_planning"}
        )

    response_text = (
        "Xin chao! Minh la tro ly tai chinh cua ban.\n\n"
        "Minh co the giup ban:\n"
        "- Tu van ve tiet kiem va dau tu\n"
        "- Giai quyet van de chi tieu vuot muc\n"
        "- Lap ke hoach tai chinh\n"
        "- Dua ra goi y cat giam chi phi\n\n"
        "Ban dang gap van de gi ve tai chinh khong?"
    )

    return ChatResponse(
        message=response_text,
        action=None,
        response_metadata={}
    )
