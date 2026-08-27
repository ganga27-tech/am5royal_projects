import asyncio
from app.db.session import AsyncSessionLocal
from sqlalchemy import text

async def execute_ignore_error(db, query, params):
    try:
        await db.execute(text(query), params)
        await db.commit()
    except Exception as e:
        await db.rollback()

async def delete_vendors():
    mobiles = [
        '9493221156', '8374344672', '9000278199', '8317647437', '8121449904', 
        '9010963545', '9666358459', '8885329348', '7013985800', '9059948066', 
        '8096340566', '7793982280', '7382659266', '9391148836', '8125279738', 
        '9391837062', '6304615352', '8008769860'
    ]
    
    async with AsyncSessionLocal() as db:
        for mob in mobiles:
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
                    "DELETE FROM vendor_availability WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_documents WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_services WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_sub_categories WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM bookings WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_ratings WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_wallets WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_subscriptions WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM service_vendor_association WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_categories WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM subscriptions WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM review_replies WHERE review_id IN (SELECT id FROM reviews WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid))",
                    "DELETE FROM reviews WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM employee_vendor_association WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)",
                    "DELETE FROM vendor_images WHERE vendor_id IN (SELECT id FROM vendors WHERE user_id = :uid)"
                ]
                
                # Delete dependencies of users
                user_queries = [
                    "DELETE FROM vendors WHERE user_id = :uid",
                    "DELETE FROM customers WHERE user_id = :uid",
                    "DELETE FROM auth_sessions WHERE user_id = :uid",
                    "DELETE FROM device_user_mapping WHERE user_id = :uid",
                    "DELETE FROM notifications WHERE user_id = :uid",
                    "DELETE FROM device_installations WHERE user_id = :uid",
                    "DELETE FROM users WHERE id = :uid"
                ]
                
                for q in vendor_queries:
                    await execute_ignore_error(db, q, {"uid": user.id})
                
                for q in user_queries:
                    await execute_ignore_error(db, q, {"uid": user.id})
                    
                print(f" -> Processed {mob}.")
            else:
                print(f"User with mobile {mob} not found in database.")
        
    print("Cleanup complete.")

if __name__ == "__main__":
    asyncio.run(delete_vendors())
