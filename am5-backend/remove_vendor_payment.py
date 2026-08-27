import asyncio
from sqlalchemy import text
from app.db.session import AsyncSessionLocal
import sys

async def remove_vendor_subscriptions(mobile: str):
    async with AsyncSessionLocal() as db:
        user_res = await db.execute(text("SELECT id FROM users WHERE mobile = :m"), {"m": mobile})
        user = user_res.fetchone()
        
        if not user:
            print(f"User with mobile {mobile} not found.")
            return
            
        vendor_res = await db.execute(text("SELECT id FROM vendors WHERE user_id = :uid"), {"uid": user.id})
        vendor = vendor_res.fetchone()
        
        if not vendor:
            print(f"No vendor found for user {user.id}.")
            return
            
        print(f"Found Vendor ID {vendor.id} for phone {mobile}. Deleting all subscriptions...")
        
        # Delete vendor subscriptions
        await db.execute(text("DELETE FROM vendor_subscriptions WHERE vendor_id = :vid"), {"vid": vendor.id})
        
        # Keep vendor in onboarding so payment APIs and status sync keep working.
        await db.execute(
            text("UPDATE vendors SET status = 'onboarding' WHERE id = :vid"),
            {"vid": vendor.id},
        )
        await db.commit()
        
        print(
            f"Successfully deleted subscription records for vendor {vendor.id} ({mobile}). "
            "Vendor status set to 'onboarding' for payment retest."
        )

if __name__ == "__main__":
    mob = sys.argv[1] if len(sys.argv) > 1 else "8919730797"
    asyncio.run(remove_vendor_subscriptions(mob))
