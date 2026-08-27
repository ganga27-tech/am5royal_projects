import asyncio
from sqlalchemy import text
from app.db.session import AsyncSessionLocal

async def main():
    async with AsyncSessionLocal() as db:
        print("Resetting telecaller points to 0...")
        
        # Reset referral_points and total_points for employees who are telecallers
        query = """
        UPDATE employees
        SET referral_points = 0, total_points = 0
        WHERE role = 'telecaller';
        """
        
        try:
            result = await db.execute(text(query))
            print(f"Successfully reset points. Rows affected: {result.rowcount}")
        except Exception as e:
            print(f"Error resetting points: {e}")
            
        await db.commit()
        print("Database commit done.")

if __name__ == "__main__":
    asyncio.run(main())
