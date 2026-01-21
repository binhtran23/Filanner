from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from typing import List

from app.api.deps import get_db, get_current_user
from app.models.users import User
from app.schemas.planner import (
    PlanCreate,
    PlanResponse,
    PlanNodeResponse,
    NodeUpdate
)
from app.crud.plans import (
    create_plan,
    get_plan_by_id,
    get_plans_by_user,
    get_plan_nodes,
    get_node_by_id,
    update_node,
    delete_plan_nodes
)
from app.utils.planner_logic import generate_plan_nodes

router = APIRouter()


@router.post("/init", response_model=PlanResponse, status_code=201)
async def initialize_plan(
    plan_data: PlanCreate,
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    """
    Create initial financial plan based on profile.
    Logic: Salary - Fixed Costs = Savings capacity -> Generate monthly nodes.
    """
    # Create plan
    plan = await create_plan(session, current_user.id, plan_data.name)
    
    # Generate nodes based on user profile
    nodes = await generate_plan_nodes(session, plan.id, current_user.id)
    
    return PlanResponse(
        id=plan.id,
        user_id=plan.user_id,
        name=plan.name,
        status=plan.status,
        created_at=plan.created_at,
        nodes=[PlanNodeResponse.model_validate(node) for node in nodes]
    )


@router.get("/{plan_id}", response_model=PlanResponse)
async def get_plan(
    plan_id: UUID,
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    """Get financial plan with all nodes."""
    plan = await get_plan_by_id(session, plan_id)
    
    if not plan:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Plan not found"
        )
    
    if plan.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to access this plan"
        )
    
    nodes = await get_plan_nodes(session, plan_id)
    
    return PlanResponse(
        id=plan.id,
        user_id=plan.user_id,
        name=plan.name,
        status=plan.status,
        created_at=plan.created_at,
        nodes=[PlanNodeResponse.model_validate(node) for node in nodes]
    )


@router.get("", response_model=List[PlanResponse])
async def list_plans(
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    """List all plans for current user."""
    plans = await get_plans_by_user(session, current_user.id, status="ACTIVE")
    
    result = []
    for plan in plans:
        nodes = await get_plan_nodes(session, plan.id)
        result.append(PlanResponse(
            id=plan.id,
            user_id=plan.user_id,
            name=plan.name,
            status=plan.status,
            created_at=plan.created_at,
            nodes=[PlanNodeResponse.model_validate(node) for node in nodes]
        ))
    
    return result


@router.patch("/nodes/{node_id}", response_model=PlanNodeResponse)
async def update_plan_node(
    node_id: UUID,
    node_data: NodeUpdate,
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    """Update plan node status or current amount."""
    node = await get_node_by_id(session, node_id)
    
    if not node:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Node not found"
        )
    
    # Verify ownership through plan
    plan = await get_plan_by_id(session, node.plan_id)
    if not plan or plan.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to update this node"
        )
    
    # Update node
    updated_node = await update_node(
        session,
        node_id,
        status=node_data.status,
        current_amount=node_data.current_amount
    )
    
    return updated_node


@router.post("/regenerate", response_model=PlanResponse)
async def regenerate_plan(
    plan_id: UUID,
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_db)
):
    """
    Regenerate plan based on actual transactions.
    Important: Recalculates nodes based on real spending patterns.
    """
    plan = await get_plan_by_id(session, plan_id)
    
    if not plan:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Plan not found"
        )
    
    if plan.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to regenerate this plan"
        )
    
    # Delete old nodes
    await delete_plan_nodes(session, plan_id)
    
    # Generate new nodes based on updated data
    nodes = await generate_plan_nodes(session, plan.id, current_user.id)
    
    return PlanResponse(
        id=plan.id,
        user_id=plan.user_id,
        name=plan.name,
        status=plan.status,
        created_at=plan.created_at,
        nodes=[PlanNodeResponse.model_validate(node) for node in nodes]
    )
