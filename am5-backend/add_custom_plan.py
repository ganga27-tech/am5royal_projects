import asyncio
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime, timedelta

from app.db.session import AsyncSessionLocal
from app.models.user_location import User
from app.models.vendor import Vendor
from app.models.subscriptions import SubscriptionPlan, VendorSubscription

async def main():
    async with AsyncSessionLocal() as db:
        # Find user
        user_query = select(User).where(User.mobile == "9581173940")
        users = await db.execute(user_query)
        user = users.scalar_one_or_none()
        if not user:
            print("User with mobile 9581173940 not found.")
            return
            
        print(f"Found User ID: {user.id}")
        
        # Find vendor
        vendor_query = select(Vendor).where(Vendor.user_id == user.id)
        vendors = await db.execute(vendor_query)
        vendor = vendors.scalar_one_or_none()
        if not vendor:
            print("Vendor for user not found.")
            return
            
        print(f"Found Vendor ID: {vendor.id}")
        
        # Find plan 2599
        plan_query = select(SubscriptionPlan).where(SubscriptionPlan.price == 2599)
        plans = await db.execute(plan_query)
        plan = plans.scalar_one_or_none()
        
        if not plan:
            print("Plan with price 2599 not found. Creating one...")
            plan = SubscriptionPlan(
                plan_type="multi_category",
                name="Custom Plan 2599",
                tier="Tier-1",
                price=2599.00,
                validity_days=30,
                is_active=True
            )
            db.add(plan)
            await db.flush()
            print(f"Created new plan ID: {plan.id} with price 2599.")
        else:
            print(f"Found existing plan ID: {plan.id} with price 2599.")
            
        # Check active subscription
        active_sub_query = select(VendorSubscription).where(
            VendorSubscription.vendor_id == vendor.id,
            VendorSubscription.status == "active"
        )
        active_sub_res = await db.execute(active_sub_query)
        existing = active_sub_res.scalar_one_or_none()
        if existing:
            print(f"Vendor already has an active subscription: {existing.id}")
            # Deactivate existing active plans
            existing.status = "expired"
            db.add(existing)
            print("Deactivated old active plan.")
            
        start_date = datetime.utcnow()
        end_date = start_date + timedelta(days=plan.validity_days)
        
        new_sub = VendorSubscription(
            vendor_id=vendor.id,
            subscription_plan_id=plan.id,
            start_date=start_date,
            end_date=end_date,
            status="active"
        )
        db.add(new_sub)
        await db.commit()
        print(f"Successfully added 2599 plan to vendor {vendor.id} (phone 9581173940)!")

asyncio.run(main())
