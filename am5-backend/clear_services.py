import asyncio
import sys
from sqlalchemy import text
from app.db.session import AsyncSessionLocal

async def clear_vendor_services_and_categories(mobile: str):
    async with AsyncSessionLocal() as db:
        user_res = await db.execute(text("SELECT id FROM users WHERE mobile = :m"), {"m": mobile})
        user = user_res.fetchone()
        if not user:
            print(f"User with mobile {mobile} not found.")
            return

        uid = user.id
        print(f"Found User ID {uid} ({mobile}).")

        vendor_res = await db.execute(text("SELECT id FROM vendors WHERE user_id = :uid"), {"uid": uid})
        vendor = vendor_res.fetchone()

        if not vendor:
            print(f"No vendor profile found for User ID {uid}.")
            return

        vid = vendor.id
        print(f"Vendor ID: {vid}")

        # Delete vendor service media
        await db.execute(text("DELETE FROM vendor_service_media WHERE vendor_service_id IN (SELECT id FROM vendor_services WHERE vendor_id = :vid)"), {"vid": vid})
        await db.commit()
        print(f"Cleared vendor_service_media for Vendor ID {vid}.")

        # Delete vendor services
        await db.execute(text("DELETE FROM vendor_services WHERE vendor_id = :vid"), {"vid": vid})
        await db.commit()
        print(f"Cleared vendor_services for Vendor ID {vid}.")

        print("Services and Categories successfully removed!")

if __name__ == "__main__":
    mob = sys.argv[1] if len(sys.argv) > 1 else "8919730797"
    asyncio.run(clear_vendor_services_and_categories(mob))
