import asyncio
import sys
from sqlalchemy import text
from app.db.session import AsyncSessionLocal

async def clear_vendor_details(mobile: str):
    async with AsyncSessionLocal() as db:
        user_res = await db.execute(text("SELECT id FROM users WHERE mobile = :m OR mobile = :m_alt"), {"m": mobile, "m_alt": f"+91{mobile}"})
        user = user_res.fetchone()
        if not user:
            print(f"User with mobile {mobile} not found in users table.")
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

        queries = [
            "DELETE FROM vendor_service_media WHERE vendor_service_id IN (SELECT id FROM vendor_services WHERE vendor_id = :vid)",
            "DELETE FROM vendor_services WHERE vendor_id = :vid",
            "DELETE FROM vendor_sub_categories WHERE vendor_id = :vid",
            "DELETE FROM vendor_subscriptions WHERE vendor_id = :vid",
            "UPDATE vendors SET status = 'onboarding', telecaller_services_updated = false WHERE id = :vid"
        ]

        for q in queries:
            try:
                await db.execute(text(q), {"vid": vid})
                await db.commit()
                print(f"Executed: {q[:45]}...")
            except Exception as e:
                await db.rollback()
                print(f"Error on query {q[:30]}: {e}")

        print(f"Successfully cleaned all selected subcategories and services for vendor mobile {mobile} (Vendor ID: {vid})!")

if __name__ == "__main__":
    mob = sys.argv[1] if len(sys.argv) > 1 else "8919730797"
    asyncio.run(clear_vendor_details(mob))
