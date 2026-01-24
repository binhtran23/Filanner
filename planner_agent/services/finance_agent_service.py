import time
import json
from prisma.enums import RequestStatus
from core.db import db
from utils.planner import generate

# 1. Khởi tạo Task (Nhận data là Dict thuần)
async def init_task_record(data: dict) -> str:
    """
    Tạo record ban đầu và trả về task_id.
    data: Dictionary chứa thông tin user input.
    """
    # Convert dict to JSON string để Prisma có thể lưu
    user_info_json = json.dumps(data, ensure_ascii=False)

    new_plan = await db.financeplan.create(
        data={
            "userId": data.get("user_id"), 
            "userName": data.get("ho_ten"), # Truy cập kiểu dict
            "userInfo": user_info_json
        }
    )

    # Tạo record Exchange trạng thái PENDING
    await db.planexchange.create(
        data={
            "financePlanId": new_plan.id,
            "status": RequestStatus.PENDING,
            "responseTime": 0,
        }
    )

    return new_plan.id

# 2. Xử lý Background (Không cần sửa nhiều, chỉ đảm bảo truyền dict)
async def process_ai_background(plan_id: str, data: dict):
    """
    Hàm này sẽ được gọi bởi BackgroundTasks của FastAPI
    """
    # Tìm exchange mới nhất
    current_exchange = await db.planexchange.find_first(
        where={"financePlanId": plan_id},
        order={"id": "desc"}
    )
    
    if not current_exchange:
        return

    exchange_id = current_exchange.id

    try:
        # Update -> PROCESSING
        await db.planexchange.update(
            where={"id": exchange_id},
            data={"status": RequestStatus.PROCESSING}
        )

        start_time = time.time()
        
        # Gọi AI (data đã là dict, truyền thẳng vào)
        advice_json_string = await generate(data) 
        
        duration_ms = int((time.time() - start_time) * 1000)

        # Nếu AI lỗi hoặc trả về rỗng
        if not advice_json_string:
            raise Exception("AI returned empty response")

        # Update -> COMPLETED
        await db.planexchange.update(
            where={"id": exchange_id},
            data={
                "plan": advice_json_string, # Lưu chuỗi JSON vào DB
                "responseTime": duration_ms,
                "successCode": 200,
                "status": RequestStatus.COMPLETED
            }
        )

    except Exception as e:
        print(f"[AI-Worker] Failed: {e}")
        await db.planexchange.update(
            where={"id": exchange_id},
            data={
                "successCode": 500,
                "errorMessage": str(e),
                "status": RequestStatus.FAILED
            }
        )

# 3. Lấy kết quả 
async def get_task_result(plan_id: str) -> dict:
    plan = await db.financeplan.find_unique(
        where={"id": plan_id},
        include={"plans": True} 
    )

    if not plan:
        return {"status": "NOT_FOUND", "message": "Task ID not found"}

    # Mặc định
    result = {
        "task_id": plan.id,
        "created_at": plan.createdAt,
        "status": "PENDING",
        "data": None,
        "error": None
    }

    # Lấy trạng thái từ record con mới nhất
    if plan.plans and len(plan.plans) > 0:
        last_exchange = plan.plans[-1]
        
        status_obj = last_exchange.status
        status_str = status_obj.name if hasattr(status_obj, "name") else str(status_obj)

        result["status"] = status_str
        
        # Use string comparison to be safe
        if status_str == "COMPLETED":
            # Parse string JSON trong DB thành Dict để trả về frontend
            try:
                result["data"] = json.loads(last_exchange.plan)
            except:
                result["data"] = last_exchange.plan # Fallback nếu không phải JSON
        
        elif status_str == "FAILED":
            result["error"] = last_exchange.errorMessage

    return result