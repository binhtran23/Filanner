from sqlmodel import Session
from uuid import UUID
from datetime import datetime, timedelta
from typing import List

from app.models.financial_plans import PlanNode, NodeType
from sqlmodel import select
from app.models.users import Profile


def generate_plan_nodes(session: Session, plan_id: UUID, user_id: UUID) -> List[PlanNode]:
    profile = session.exec(select(Profile).where(Profile.user_id == user_id)).first()

    if not profile or not profile.current_salary:
        node = PlanNode(
            plan_id=plan_id,
            title="Hoan thien ho so tai chinh",
            node_type=NodeType.ACTION.value,
            target_amount=0,
            node_metadata={"message": "Vui long cap nhat luong va chi phi co dinh"}
        )
        session.add(node)
        session.commit()
        session.refresh(node)
        return [node]

    total_fixed_costs = sum(profile.fixed_costs.values()) if profile.fixed_costs else 0
    savings_capacity = profile.current_salary - total_fixed_costs

    if savings_capacity <= 0:
        node = PlanNode(
            plan_id=plan_id,
            title="Can doi lai ngan sach",
            node_type=NodeType.ADJUSTMENT.value,
            target_amount=0,
            node_metadata={
                "message": "Chi phi co dinh vuot qua luong. Can giam chi tieu.",
                "salary": profile.current_salary,
                "fixed_costs": total_fixed_costs,
                "deficit": abs(savings_capacity)
            }
        )
        session.add(node)
        session.commit()
        session.refresh(node)
        return [node]

    nodes = []
    current_date = datetime.utcnow()
    parent_id = None

    for month in range(1, 13):
        deadline = current_date + timedelta(days=30 * month)
        monthly_target = savings_capacity * 0.7

        node = PlanNode(
            plan_id=plan_id,
            title=f"Tiet kiem thang {month}",
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
        session.add(node)
        session.commit()
        session.refresh(node)

        nodes.append(node)
        parent_id = node.id

    total_target = savings_capacity * 0.7 * 12
    milestone = PlanNode(
        plan_id=plan_id,
        title="Muc tieu tiet kiem nam",
        node_type=NodeType.MILESTONE.value,
        target_amount=total_target,
        parent_node_id=parent_id,
        deadline=current_date + timedelta(days=365),
        node_metadata={
            "total_months": 12,
            "estimated_savings": total_target
        }
    )
    session.add(milestone)
    session.commit()
    session.refresh(milestone)

    nodes.append(milestone)
    return nodes
