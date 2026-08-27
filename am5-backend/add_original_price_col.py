import asyncio
from sqlalchemy import text
from app.db.session import AsyncSessionLocal

async def alter_db():
    async with AsyncSessionLocal() as session:
        try:
            # Check if column exists, if not, add it
            # This is specific to PostgreSQL
            await session.execute(text("ALTER TABLE subscription_plans ADD COLUMN original_price NUMERIC(10, 2);"))
            await session.commit()
            print("Successfully added original_price column to subscription_plans.")
        except Exception as e:
            print(f"Failed to add column (it might already exist): {e}")

if __name__ == "__main__":
    asyncio.run(alter_db())
