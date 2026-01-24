# app/controllers/finance_controller.py
from fastapi import APIRouter, HTTPException, BackgroundTasks, status
from dtos.finance_dto import UserProfileRequest, TaskResponse, PlanResultResponse, TaskStatus
from services import finance_service

router = APIRouter(prefix="/api/v1/model", tags=["Finance Model"])

@router.post("/generate", status_code=status.HTTP_202_ACCEPTED, response_model=TaskResponse)
async def generate_plan(payload: UserProfileRequest, background_tasks: BackgroundTasks):
    """
    API nhận request và đẩy vào background xử lý.
    Trả về task_id ngay lập tức.
    """
    try:
        # 1. Tạo record PENDING
        task_id = await finance_service.init_task_record(payload)

        # 2. Đẩy vào Background Task (Chạy ngầm)
        background_tasks.add_task(finance_service.process_ai_background, task_id, payload)

        return TaskResponse(
            task_id=task_id,
            status=TaskStatus.PENDING,
            message="Request accepted. Processing in background."
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/plans/{task_id}", response_model=PlanResultResponse)
async def get_plan(task_id: str):
    """
    Backend App gọi API này định kỳ để kiểm tra kết quả.
    """
    result = await finance_service.get_task_result(task_id)
    
    if result.status == TaskStatus.NOT_FOUND:
        raise HTTPException(status_code=404, detail="Plan ID not found")
        
    return result