import asyncio
from sqlalchemy import text
from app.db.session import engine

async def main():
    query = text("""
        SELECT 
            u.id as user_id,
            u.mobile as user_mobile,
            u.email as user_email,
            u.role as user_role,
            u.otp_verified,
            v.id as vendor_id,
            v.first_name,
            v.last_name,
            v.business_name,
            (
                CASE
                    WHEN EXISTS (SELECT 1 FROM vendor_subscriptions vs WHERE vs.vendor_id = v.id AND vs.status = 'active') THEN 'payment'
                    WHEN EXISTS (SELECT 1 FROM vendor_availability va WHERE va.vendor_id = v.id) THEN 'slot booking'
                    WHEN EXISTS (SELECT 1 FROM vendor_sub_categories vsc WHERE vsc.vendor_id = v.id) OR EXISTS (SELECT 1 FROM vendor_services vsr WHERE vsr.vendor_id = v.id) THEN 'subcategory'
                    WHEN v.id IS NOT NULL AND (v.first_name IS NOT NULL AND v.first_name != '' OR v.business_name IS NOT NULL AND v.business_name != '') THEN 'registration'
                    ELSE 'only otp verified'
                END
            ) as step
        FROM users u
        LEFT JOIN vendors v ON v.user_id = u.id
        WHERE u.role LIKE '%VENDOR%'
        ORDER BY u.created_at DESC
    """)

    async with engine.connect() as conn:
        result = await conn.execute(query)
        rows = result.fetchall()
        print(f"Total users with role VENDOR: {len(rows)}")
        
        counts = {}
        for r in rows:
            step = r.step
            counts[step] = counts.get(step, 0) + 1
            
        print("Counts by step:")
        for step, count in counts.items():
            print(f"  {step}: {count}")

if __name__ == "__main__":
    asyncio.run(main())
