# app/services/finance_service.py
import asyncio
import time
from prisma.enums import RequestStatus
from core.db import db
from dtos.finance_dto import UserProfileRequest, TaskStatus, PlanResultResponse
from utils.planner import generate

# 1. Khởi tạo Task (Đồng bộ - Trả về nhanh)
async def init_task_record(data: UserProfileRequest) -> str:
    new_plan = await db.financeplan.create(
        data={
            "userId": data.external_user_id,
            "status": RequestStatus.PENDING 
        }
    )
    return new_plan.id

# 2. Xử lý AI (Bất đồng bộ - Chạy ngầm)
async def process_ai_background(plan_id: str, data: UserProfileRequest):
    try:
        # A. Cập nhật status -> PROCESSING
        await db.financeplan.update(
            where={"id": plan_id},
            data={"status": RequestStatus.PROCESSING}
        )

        # B. Giả lập logic AI (Mocking)
        start_time = time.time()

        advice = await generate(data)
        

        duration_ms = int((time.time() - start_time) * 1000)

        # C. Lưu kết quả vào bảng con
        await db.planexchange.create(
            data={
                "financePlanId": plan_id,
                "plan": advice,
                "responseTime": duration_ms,
                "successCode": 200
            }
        )

        # D. Cập nhật status -> COMPLETED
        await db.financeplan.update(
            where={"id": plan_id},
            data={"status": RequestStatus.COMPLETED}
        )
        print(f"[AI-Worker] Task {plan_id} completed.")

    except Exception as e:
        print(f"[AI-Worker] Task {plan_id} failed: {e}")
        # Lưu lỗi
        await db.planexchange.create(
            data={
                "financePlanId": plan_id,
                "successCode": 500,
                "errorMessage": str(e),
                "responseTime": 0
            }
        )
        # Update status failed
        await db.financeplan.update(
            where={"id": plan_id},
            data={"status": RequestStatus.FAILED}
        )

# 3. Lấy kết quả (Polling)
async def get_task_result(plan_id: str) -> PlanResultResponse:
    plan = await db.financeplan.find_unique(
        where={"id": plan_id},
        include={"plans": True}
    )

    if not plan:
        return PlanResultResponse(
            task_id=plan_id, 
            status=TaskStatus.NOT_FOUND,
            error_message="Task ID not found"
        )

    # Lấy nội dung từ bảng con nếu đã xong
    content = None
    error = None
    if plan.plans:
        last_exchange = plan.plans[-1]
        content = last_exchange.plan
        error = last_exchange.errorMessage

    return PlanResultResponse(
        task_id=plan.id,
        status=plan.status.value, # Convert Enum Prisma -> String
        plan_content=content,
        error_message=error,
        created_at=plan.createdAt,
        updated_at=plan.updatedAt
    )