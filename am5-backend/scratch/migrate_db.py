import asyncio
import asyncpg

async def main():
    conn = await asyncpg.connect("postgresql://am5royal_user:am5royal%4012345@76.13.245.174:5433/am5royal")
    print("Connected to database.")
    
    # Check if columns already exist
    cols = await conn.fetch("""
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'vendors' AND column_name IN ('feedback', 'payment_info')
    """)
    existing_cols = {c['column_name'] for c in cols}
    
    if 'feedback' not in existing_cols:
        print("Adding feedback column to vendors table...")
        await conn.execute("ALTER TABLE vendors ADD COLUMN feedback TEXT;")
    else:
        print("feedback column already exists.")
        
    if 'payment_info' not in existing_cols:
        print("Adding payment_info column to vendors table...")
        await conn.execute("ALTER TABLE vendors ADD COLUMN payment_info VARCHAR(100);")
    else:
        print("payment_info column already exists.")
        
    print("Migration completed successfully.")
    await conn.close()

asyncio.run(main())
