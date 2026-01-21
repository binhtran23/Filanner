from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import SQLModel

from app.db.session import engine
from app.models.users import User
from app.models.profiles import Profile
from app.models.transactions import Transaction
from app.models.financial_plans import FinancialPlan
from app.models.plan_nodes import PlanNode
from app.models.daily_check_ins import DailyCheckIn
from app.models.rewards import Reward
from app.models.user_rewards import UserReward


async def init_db():
    """Initialize database: create all tables."""
    async with engine.begin() as conn:
        # Create all tables
        await conn.run_sync(SQLModel.metadata.create_all)
    
    print("✅ Database tables created successfully!")


async def seed_rewards():
    """Seed initial rewards data for gamification."""
    from app.db.session import AsyncSessionLocal
    
    rewards_data = [
        {
            "name": "Khô gà",
            "cost_point": 50,
            "image_url": "https://cdn.filanner.com/rewards/kho-ga.png",
            "description": "Một gói khô gà thơm ngon"
        },
        {
            "name": "Gấu bông mini",
            "cost_point": 100,
            "image_url": "https://cdn.filanner.com/rewards/gau-bong.png",
            "description": "Gấu bông dễ thương"
        },
        {
            "name": "Voucher cafe",
            "cost_point": 150,
            "image_url": "https://cdn.filanner.com/rewards/voucher-cafe.png",
            "description": "Voucher 50k mua cafe"
        },
        {
            "name": "Sách tài chính",
            "cost_point": 300,
            "image_url": "https://cdn.filanner.com/rewards/sach.png",
            "description": "Sách hướng dẫn đầu tư tài chính"
        },
        {
            "name": "Voucher mua sắm 200k",
            "cost_point": 500,
            "image_url": "https://cdn.filanner.com/rewards/voucher-shopping.png",
            "description": "Voucher mua sắm trị giá 200k"
        },
    ]
    
    async with AsyncSessionLocal() as session:
        for reward_data in rewards_data:
            reward = Reward(**reward_data)
            session.add(reward)
        
        await session.commit()
    
    print("✅ Rewards seeded successfully!")


if __name__ == "__main__":
    import asyncio
    
    async def main():
        print("🔧 Initializing database...")
        await init_db()
        
        print("🎁 Seeding rewards...")
        await seed_rewards()
        
        print("✨ Database initialization complete!")
    
    asyncio.run(main())
