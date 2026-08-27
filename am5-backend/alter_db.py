import asyncio
from sqlalchemy import text
from app.db.session import AsyncSessionLocal

async def main():
    async with AsyncSessionLocal() as db:
        print("Altering vendors table...")
        
        queries = [
            "ALTER TABLE vendors ADD COLUMN IF NOT EXISTS email VARCHAR;",
            "ALTER TABLE vendors ADD COLUMN IF NOT EXISTS alternative_number VARCHAR;",
            "ALTER TABLE vendors ADD COLUMN IF NOT EXISTS father_name VARCHAR;"
        ]
        
        for query in queries:
            try:
                await db.execute(text(query))
                print(f"Executed: {query}")
            except Exception as e:
                print(f"Error executing {query}: {e}")
                
        await db.commit()
        print("Done")

if __name__ == "__main__":
    asyncio.run(main())
