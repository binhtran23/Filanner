from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from uuid import UUID
from datetime import datetime
from typing import List, Optional
from app.models.financial_plans import FinancialPlan
from app.models.plan_nodes import PlanNode


async def create_plan(
    session: AsyncSession,
    user_id: UUID,
    name: str
) -> FinancialPlan:
    """Create a new financial plan."""
    plan = FinancialPlan(user_id=user_id, name=name)
    session.add(plan)
    await session.commit()
    await session.refresh(plan)
    return plan


async def get_plan_by_id(
    session: AsyncSession,
    plan_id: UUID
) -> Optional[FinancialPlan]:
    """Get plan by ID."""
    result = await session.execute(
        select(FinancialPlan).where(FinancialPlan.id == plan_id)
    )
    return result.scalar_one_or_none()


async def get_plans_by_user(
    session: AsyncSession,
    user_id: UUID,
    status: Optional[str] = None
) -> List[FinancialPlan]:
    """Get all plans for a user."""
    query = select(FinancialPlan).where(FinancialPlan.user_id == user_id)
    
    if status:
        query = query.where(FinancialPlan.status == status)
    
    query = query.order_by(FinancialPlan.created_at.desc())
    
    result = await session.execute(query)
    return list(result.scalars().all())


async def create_plan_node(
    session: AsyncSession,
    plan_id: UUID,
    title: str,
    node_type: str,
    target_amount: Optional[float] = None,
    parent_node_id: Optional[UUID] = None,
    deadline: Optional[datetime] = None,
    node_metadata: dict = None
) -> PlanNode:
    """Create a new plan node."""
    node = PlanNode(
        plan_id=plan_id,
        title=title,
        node_type=node_type,
        target_amount=target_amount,
        parent_node_id=parent_node_id,
        deadline=deadline,
        node_metadata=node_metadata or {}
    )
    session.add(node)
    await session.commit()
    await session.refresh(node)
    return node


async def get_plan_nodes(
    session: AsyncSession,
    plan_id: UUID
) -> List[PlanNode]:
    """Get all nodes for a plan."""
    result = await session.execute(
        select(PlanNode)
        .where(PlanNode.plan_id == plan_id)
        .order_by(PlanNode.created_at)
    )
    return list(result.scalars().all())


async def get_node_by_id(
    session: AsyncSession,
    node_id: UUID
) -> Optional[PlanNode]:
    """Get node by ID."""
    result = await session.execute(
        select(PlanNode).where(PlanNode.id == node_id)
    )
    return result.scalar_one_or_none()


async def update_node(
    session: AsyncSession,
    node_id: UUID,
    status: Optional[str] = None,
    current_amount: Optional[float] = None
) -> Optional[PlanNode]:
    """Update a plan node."""
    node = await get_node_by_id(session, node_id)
    
    if node:
        if status is not None:
            node.status = status
        if current_amount is not None:
            node.current_amount = current_amount
        
        session.add(node)
        await session.commit()
        await session.refresh(node)
    
    return node


async def delete_plan_nodes(session: AsyncSession, plan_id: UUID):
    """Delete all nodes for a plan (for regeneration)."""
    result = await session.execute(
        select(PlanNode).where(PlanNode.plan_id == plan_id)
    )
    nodes = result.scalars().all()
    for node in nodes:
        await session.delete(node)
    await session.commit()
