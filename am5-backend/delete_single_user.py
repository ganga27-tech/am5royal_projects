import asyncio
from app.db.session import AsyncSessionLocal
from sqlalchemy import text
import sys

async def execute_ignore_error(db, query, params):
    try:
        await db.execute(text(query), params)
        await db.commit()
    except Exception as e:
        await db.rollback()

async def delete_vendors():
    target_mobiles = sys.argv[1:] if len(sys.argv) > 1 else ['8919730797']
    print(f"Targeting mobiles for deletion: {target_mobiles}")
    
    async with AsyncSessionLocal() as db:
        for mob in target_mobiles:
            try:
                result = await db.execute(text("SELECT id FROM users WHERE mobile = :m"), {"m": mob})
                user = result.fetchone()
                await db.commit()
            except Exception as e:
                await db.rollback()
                continue
                
            if user:
                print(f"Deleting user {user.id} with mobile {mob}...")
                
                # Delete dependencies of vendors
                vendor_queries = [
                    "DELETE FROM vendor_service_media WHERE vendor_service_id IN (SELECT id FROM vendor_services WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid))",
                    "DELETE FROM vendor_availability WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_documents WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_services WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_sub_categories WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM bookings WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_ratings WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_wallets WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_subscriptions WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_categories WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM subscriptions WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM review_replies WHERE review_id IN (SELECT id FROM reviews WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid))",
                    "DELETE FROM reviews WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM employee_vendor_association WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_images WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)"
                ]
                
                # Delete dependencies of users
                user_queries = [
                    "DELETE FROM vendor_sales_media WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_monthly_histories WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_lead_views WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM lead_calls WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM leads WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendors WHERE user_id = :uid",
                    "DELETE FROM customers WHERE user_id = :uid",
                    "DELETE FROM auth_sessions WHERE user_id = :uid",
                    "DELETE FROM device_user_mapping WHERE user_id = :uid",
                    "DELETE FROM notifications WHERE user_id = :uid",
                    "DELETE FROM device_installations WHERE user_id = :uid",
                    "DELETE FROM users WHERE id = :uid"
                ]
                
                for q in vendor_queries + user_queries:
                    try:
                        await db.execute(text(q), {"uid": user.id})
                        await db.commit()
                    except Exception as e:
                        await db.rollback()
                        print(f"Skipping query failure for {q}: {e}")

                print(f" -> Successfully deleted mobile {mob} (user id {user.id}).")
            else:
                print(f"User with mobile {mob} not found in users table.")
        
    print("Cleanup complete.")

if __name__ == "__main__":
    asyncio.run(delete_vendors())
