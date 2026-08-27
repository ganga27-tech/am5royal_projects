import asyncio
from sqlalchemy import text
from app.db.session import AsyncSessionLocal

async def main():
    async with AsyncSessionLocal() as db:
        print("Altering vendors table for telecaller flow...")
        
        queries = [
            "ALTER TABLE vendors ADD COLUMN IF NOT EXISTS telecaller_services_updated BOOLEAN DEFAULT FALSE;"
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
