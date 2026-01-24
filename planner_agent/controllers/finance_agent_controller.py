from fastapi import APIRouter, BackgroundTasks, HTTPException, Body
# Import các hàm service đã viết ở bước trước
from services.finance_agent_service import init_task_record, process_ai_background, get_task_result

router = APIRouter(
    prefix="/api/finance",
    tags=["Finance Agent"]
)

@router.post("/generate-plan")
async def create_financial_plan(
    background_tasks: BackgroundTasks,
    # Sử dụng Body(..., example=...) để Swagger UI hiện ví dụ mẫu mà không cần tạo Class DTO
    user_data: dict = Body(..., example={
        "user_id": "user_123",
        "ho_ten": "Nguyễn Văn A",
        "current_day": "Thứ Hai, 24/01/2026",
        "thu_nhap_hang_thang": 20000000,
        "chi_tieu_bat_buoc": [
            {"ten_chi_tieu": "Tiền nhà", "uoc_tinh": 5000000, "tan_suat": "Tháng", "note": "Cố định"}
        ],
        "muc_tieu": "Mua xe máy mới"
    })
):
    """
    API tạo task lập kế hoạch.
    - Input: JSON (Dict)
    - Output: Task ID ngay lập tức (không đợi AI chạy xong)
    """
    
    # 1. Validate cơ bản
    if "user_id" not in user_data:
        raise HTTPException(status_code=400, detail="Missing user_id")

    try:
        # 2. Tạo record trong DB
        task_id = await init_task_record(user_data)

        # 3. Đẩy việc cho AI chạy ngầm 

        background_tasks.add_task(process_ai_background, task_id, user_data)

        # 4. Trả về kết quả ngay lập tức
        return {
            "status": "submitted",
            "task_id": task_id,
            "message": "Hệ thống đang xử lý kế hoạch tài chính...",
            "poll_url": f"/api/finance/result/{task_id}"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/result/{task_id}")
async def get_plan_result_endpoint(task_id: str):
    """
    API Polling để lấy kết quả.
    Frontend gọi API này mỗi 2-3s cho đến khi status = COMPLETED
    """
    result = await get_task_result(task_id)

    # Xử lý lỗi nếu không tìm thấy task
    if result.get("status") == "NOT_FOUND":
        raise HTTPException(status_code=404, detail="Task ID not found")

    return result