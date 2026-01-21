from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID
from datetime import datetime, timedelta
from typing import List

from app.models.plan_nodes import PlanNode, NodeType, NodeStatus
from app.crud.profiles import get_profile_by_user_id
from app.crud.plans import create_plan_node


async def generate_plan_nodes(
    session: AsyncSession,
    plan_id: UUID,
    user_id: UUID
) -> List[PlanNode]:
    """
    Generate financial plan nodes based on user profile.
    
    Logic:
    1. Get user profile (salary, fixed costs)
    2. Calculate: Salary - Fixed Costs = Savings Capacity
    3. Generate monthly saving nodes
    """
    # Get user profile
    profile = await get_profile_by_user_id(session, user_id)
    
    if not profile or not profile.current_salary:
        # Create default placeholder node if no profile
        node = await create_plan_node(
            session,
            plan_id=plan_id,
            title="Hoàn thiện hồ sơ tài chính",
            node_type=NodeType.ACTION.value,
            target_amount=0,
            node_metadata={"message": "Vui lòng cập nhật lương và chi phí cố định"}
        )
        return [node]
    
    # Calculate total fixed costs
    total_fixed_costs = sum(profile.fixed_costs.values()) if profile.fixed_costs else 0
    
    # Calculate savings capacity
    savings_capacity = profile.current_salary - total_fixed_costs
    
    if savings_capacity <= 0:
        # No savings capacity - create adjustment node
        node = await create_plan_node(
            session,
            plan_id=plan_id,
            title="Cân đối lại ngân sách",
            node_type=NodeType.ADJUSTMENT.value,
            target_amount=0,
            node_metadata={
                "message": "Chi phí cố định vượt quá lương. Cần giảm chi tiêu.",
                "salary": profile.current_salary,
                "fixed_costs": total_fixed_costs,
                "deficit": abs(savings_capacity)
            }
        )
        return [node]
    
    # Generate monthly saving nodes (12 months)
    nodes = []
    current_date = datetime.utcnow()
    parent_id = None
    
    for month in range(1, 13):
        deadline = current_date + timedelta(days=30 * month)
        
        # Suggest saving 70% of capacity (keep 30% for flexibility)
        monthly_target = savings_capacity * 0.7
        
        node = await create_plan_node(
            session,
            plan_id=plan_id,
            title=f"Tiết kiệm tháng {month}",
            node_type=NodeType.ACTION.value,
            target_amount=monthly_target,
            parent_node_id=parent_id,
            deadline=deadline,
            node_metadata={
                "month": month,
                "savings_capacity": savings_capacity,
                "suggested_percentage": 70,
                "flexible_amount": savings_capacity * 0.3
            }
        )
        
        nodes.append(node)
        parent_id = node.id  # Link next node to this one
    
    # Add milestone node at the end
    total_target = savings_capacity * 0.7 * 12
    milestone = await create_plan_node(
        session,
        plan_id=plan_id,
        title="Mục tiêu tiết kiệm năm",
        node_type=NodeType.MILESTONE.value,
        target_amount=total_target,
        parent_node_id=parent_id,
        deadline=current_date + timedelta(days=365),
        node_metadata={
            "total_months": 12,
            "estimated_savings": total_target
        }
    )
    
    nodes.append(milestone)
    
    return nodes
