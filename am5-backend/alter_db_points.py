import asyncio
from sqlalchemy import text
from app.db.session import AsyncSessionLocal

async def main():
    async with AsyncSessionLocal() as db:
        print("Creating employee_daily_points table...")
        
        query = """
        CREATE TABLE IF NOT EXISTS employee_daily_points (
            id SERIAL PRIMARY KEY,
            employee_id BIGINT REFERENCES employees(id) ON DELETE CASCADE,
            date DATE NOT NULL,
            points INTEGER DEFAULT 0,
            UNIQUE(employee_id, date)
        );
        """
        
        try:
            await db.execute(text(query))
            print("Executed employee_daily_points table creation")
        except Exception as e:
            print(f"Error executing: {e}")
            
        await db.commit()
        print("Done")

if __name__ == "__main__":
    asyncio.run(main())
