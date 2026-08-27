import asyncio
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.db.session import AsyncSessionLocal
from app.models.subscriptions import SubscriptionPlan

async def create_one_rupee_plan():
    async with AsyncSessionLocal() as db:
        # Check if 1 Rupee test plan already exists
        plan_query = select(SubscriptionPlan).where(SubscriptionPlan.price == 1.00)
        plans = await db.execute(plan_query)
        plan = plans.scalar_one_or_none()
        
        if not plan:
            print("Creating 1 Rupee Test Plan...")
            plan = SubscriptionPlan(
                plan_type="test_plan",
                name="Testing Plan (₹1)",
                tier="Test",
                price=1.00,
                original_price=100.00,
                validity_days=1,
                is_active=True
            )
            db.add(plan)
            await db.commit()
            await db.refresh(plan)
            print(f"Successfully created 1 Rupee Plan (ID: {plan.id}, Price: ₹1.00)!")
        else:
            plan.is_active = True
            await db.commit()
            print(f"1 Rupee Plan already exists (ID: {plan.id}, Price: ₹1.00). Ensured it is active.")

if __name__ == "__main__":
    asyncio.run(create_one_rupee_plan())
