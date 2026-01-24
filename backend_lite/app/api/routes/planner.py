from fastapi import APIRouter, Depends, HTTPException, status
from uuid import UUID
from typing import List, Optional

from sqlmodel import Session
from app.api.deps import get_db, get_current_user
from app.models.users import User
from app.models.financial_plans import (
    PlanCreate,
    PlanResponse,
    PlanNodeResponse,
    NodeUpdate,
    FinancialPlan,
    PlanNode,
    PlanStatus,
)
from app.utils.planner_logic import generate_plan_nodes
from sqlmodel import select

router = APIRouter()


@router.post("/init", response_model=PlanResponse, status_code=201)
def initialize_plan(
    plan_data: PlanCreate,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db)
):
    plan = FinancialPlan(user_id=current_user.id, name=plan_data.name)
    session.add(plan)
    session.commit()
    session.refresh(plan)

    nodes = generate_plan_nodes(session, plan.id, current_user.id)

    return PlanResponse(
        id=plan.id,
        user_id=plan.user_id,
        name=plan.name,
        status=plan.status,
        created_at=plan.created_at,
        nodes=[PlanNodeResponse.model_validate(node) for node in nodes]
    )


@router.get("", response_model=List[PlanResponse])
def list_plans(
    status: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db)
):
    status_filter = (status or PlanStatus.ACTIVE.value).upper()
    plans = session.exec(
        select(FinancialPlan)
        .where(FinancialPlan.user_id == current_user.id)
        .where(FinancialPlan.status == status_filter)
        .order_by(FinancialPlan.created_at.desc())
    ).all()

    result = []
    for plan in plans:
        nodes = session.exec(
            select(PlanNode)
            .where(PlanNode.plan_id == plan.id)
            .order_by(PlanNode.created_at)
        ).all()
        result.append(PlanResponse(
            id=plan.id,
            user_id=plan.user_id,
            name=plan.name,
            status=plan.status,
            created_at=plan.created_at,
            nodes=[PlanNodeResponse.model_validate(node) for node in nodes]
        ))

    return result


@router.get("/plans", response_model=List[PlanResponse])
def list_plans_alias(
    status: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db)
):
    return list_plans(status=status, current_user=current_user, session=session)


@router.get("/plans/{plan_id}", response_model=PlanResponse)
def get_plan_alias(
    plan_id: UUID,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db)
):
    return get_plan(plan_id=plan_id, current_user=current_user, session=session)


@router.get("/{plan_id}", response_model=PlanResponse)
def get_plan(
    plan_id: UUID,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db)
):
    plan = session.exec(select(FinancialPlan).where(FinancialPlan.id == plan_id)).first()

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

    nodes = session.exec(
        select(PlanNode)
        .where(PlanNode.plan_id == plan_id)
        .order_by(PlanNode.created_at)
    ).all()

    return PlanResponse(
        id=plan.id,
        user_id=plan.user_id,
        name=plan.name,
        status=plan.status,
        created_at=plan.created_at,
        nodes=[PlanNodeResponse.model_validate(node) for node in nodes]
    )


@router.post("/generate", response_model=PlanResponse, status_code=201)
def generate_plan(
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db)
):
    plan = FinancialPlan(user_id=current_user.id, name="Financial Plan")
    session.add(plan)
    session.commit()
    session.refresh(plan)

    nodes = generate_plan_nodes(session, plan.id, current_user.id)

    return PlanResponse(
        id=plan.id,
        user_id=plan.user_id,
        name=plan.name,
        status=plan.status,
        created_at=plan.created_at,
        nodes=[PlanNodeResponse.model_validate(node) for node in nodes]
    )


@router.patch("/nodes/{node_id}", response_model=PlanNodeResponse)
def update_plan_node(
    node_id: UUID,
    node_data: NodeUpdate,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db)
):
    node = session.exec(select(PlanNode).where(PlanNode.id == node_id)).first()

    if not node:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Node not found"
        )

    plan = session.exec(select(FinancialPlan).where(FinancialPlan.id == node.plan_id)).first()
    if not plan or plan.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to update this node"
        )

    if node_data.status is not None:
        node.status = node_data.status
    if node_data.current_amount is not None:
        node.current_amount = node_data.current_amount

    session.add(node)
    session.commit()
    session.refresh(node)
    return node


@router.put("/nodes/{node_id}", response_model=PlanNodeResponse)
def update_plan_node_alias(
    node_id: UUID,
    node_data: NodeUpdate,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db)
):
    return update_plan_node(
        node_id=node_id,
        node_data=node_data,
        current_user=current_user,
        session=session,
    )


@router.post("/regenerate", response_model=PlanResponse)
def regenerate_plan(
    plan_id: UUID,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_db)
):
    plan = session.exec(select(FinancialPlan).where(FinancialPlan.id == plan_id)).first()

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

    nodes = session.exec(select(PlanNode).where(PlanNode.plan_id == plan_id)).all()
    for node in nodes:
        session.delete(node)
    session.commit()
    nodes = generate_plan_nodes(session, plan.id, current_user.id)

    return PlanResponse(
        id=plan.id,
        user_id=plan.user_id,
        name=plan.name,
        status=plan.status,
        created_at=plan.created_at,
        nodes=[PlanNodeResponse.model_validate(node) for node in nodes]
    )
