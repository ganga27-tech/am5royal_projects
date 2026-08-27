import asyncio
from app.db.session import AsyncSessionLocal
from app.models.subscriptions import SubscriptionPlan, VendorSubscription
from sqlalchemy import delete

async def delete_all_plans():
    async with AsyncSessionLocal() as session:
        await session.execute(delete(VendorSubscription))
        await session.execute(delete(SubscriptionPlan))
        await session.commit()
        print("All plans and vendor subscriptions deleted successfully")

if __name__ == "__main__":
    asyncio.run(delete_all_plans())
