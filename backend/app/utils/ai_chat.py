from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID

from app.schemas.chat import ChatResponse
from app.crud.profiles import get_profile_by_user_id
from app.crud.transactions import get_transaction_summary
from datetime import datetime, timedelta


async def generate_ai_response(
    session: AsyncSession,
    user_id: UUID,
    message: str
) -> ChatResponse:
    """
    Generate AI advisor response.
    
    For hackathon: Returns rule-based responses.
    For production: Integrate with actual AI service (LangGraph, OpenAI, etc.)
    """
    message_lower = message.lower()
    
    # Get user context
    profile = await get_profile_by_user_id(session, user_id)
    
    # Get this month's transactions
    now = datetime.utcnow()
    start_of_month = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    summary = await get_transaction_summary(
        session,
        user_id=user_id,
        start_date=start_of_month
    )
    
    # Rule-based responses for demo
    
    # Overspending detection
    if any(word in message_lower for word in ["tiêu lố", "chi tiêu quá", "vượt quá", "lỡ mua"]):
        total_fixed = sum(profile.fixed_costs.values()) if profile and profile.fixed_costs else 0
        budget_left = profile.current_salary - total_fixed - summary["total_expense"] if profile else 0
        
        response_text = f"""
Mình hiểu rồi, đừng lo! 😊

Chi tiêu vượt dự kiến xảy ra với ai cũng có. Đây là gợi ý:

1. **Đánh giá lại**: Xem món đó có thực sự cần thiết không?
2. **Cắt giảm chi tiêu khác**: Giảm chi tiêu giải trí hoặc ăn uống ngoài tháng này.
3. **Tăng thu nhập**: Cân nhắc làm thêm hoặc bán đồ cũ.

Ngân sách còn lại tháng này: **{budget_left:,.0f} VND**

Bạn vẫn có thể cân bằng được! 💪
        """.strip()
        
        return ChatResponse(
            message=response_text,
            action="SUGGEST_SAVING",
            response_metadata={
                "budget_remaining": budget_left,
                "overspending_detected": True
            }
        )
    
    # Saving advice
    elif any(word in message_lower for word in ["tiết kiệm", "save", "để dành"]):
        if profile and profile.current_salary:
            total_fixed = sum(profile.fixed_costs.values()) if profile.fixed_costs else 0
            savings_capacity = profile.current_salary - total_fixed
            suggested_savings = savings_capacity * 0.3  # 30% rule
            
            response_text = f"""
Tuyệt vời khi bạn muốn tiết kiệm! 💰

**Quy tắc 50-30-20:**
- 50% chi tiêu thiết yếu
- 30% chi tiêu cá nhân
- 20% tiết kiệm/đầu tư

Với lương của bạn, mình gợi ý tiết kiệm: **{suggested_savings:,.0f} VND/tháng**

Đó là một bước khởi đầu tốt! 🎯
            """.strip()
            
            return ChatResponse(
                message=response_text,
                action="SUGGEST_SAVING",
                response_metadata={
                    "suggested_amount": suggested_savings,
                    "savings_rule": "50-30-20"
                }
            )
    
    # Budget planning
    elif any(word in message_lower for word in ["kế hoạch", "plan", "lập ngân sách"]):
        response_text = """
Tuyệt vời! Lập kế hoạch tài chính là bước đầu quan trọng. 📊

**Bước 1**: Cập nhật đầy đủ thu nhập và chi phí cố định
**Bước 2**: Theo dõi mọi khoản chi tiêu hàng ngày
**Bước 3**: Tạo mục tiêu tài chính cụ thể
**Bước 4**: Điều chỉnh khi cần thiết

Bắt đầu từ việc nhỏ nhất nhé! 🚀
        """.strip()
        
        return ChatResponse(
            message=response_text,
            action="CREATE_PLAN",
            response_metadata={"suggestion": "start_planning"}
        )
    
    # Default response
    else:
        response_text = """
Xin chào! Mình là trợ lý tài chính của bạn. 🤖

Mình có thể giúp bạn:
- Tư vấn về tiết kiệm và đầu tư
- Giải quyết vấn đề chi tiêu vượt mức
- Lập kế hoạch tài chính
- Đưa ra gợi ý cắt giảm chi phí

Bạn đang gặp vấn đề gì về tài chính không?
        """.strip()
        
        return ChatResponse(
            message=response_text,
            action=None,
            response_metadata={}
        )
