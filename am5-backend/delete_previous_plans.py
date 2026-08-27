import asyncio
from app.db.session import AsyncSessionLocal
from app.models.subscriptions import SubscriptionPlan, VendorSubscription
from sqlalchemy import delete, select

async def delete_previous():
    async with AsyncSessionLocal() as session:
        print("Finding old inactive plans to delete...")
        
        # Get old plans (is_active=False)
        query = select(SubscriptionPlan).where(SubscriptionPlan.is_active == False)
        result = await session.execute(query)
        old_plans = result.scalars().all()
        
        old_plan_ids = [p.id for p in old_plans]
        
        if not old_plan_ids:
            print("No old inactive plans found.")
            return

        print(f"Old plan IDs to delete: {old_plan_ids}")
        
        # Delete dependent vendor_subscriptions first
        print("Deleting dependent vendor_subscriptions...")
        delete_vs_stmt = delete(VendorSubscription).where(VendorSubscription.subscription_plan_id.in_(old_plan_ids))
        await session.execute(delete_vs_stmt)
        
        # Delete the old subscription plans
        print("Deleting the old subscription plans...")
        delete_sp_stmt = delete(SubscriptionPlan).where(SubscriptionPlan.id.in_(old_plan_ids))
        await session.execute(delete_sp_stmt)
        
        await session.commit()
        print("Successfully deleted previous plans and their associated vendor subscriptions.")

if __name__ == "__main__":
    asyncio.run(delete_previous())
