import asyncio
from sqlalchemy import text
from app.db.session import AsyncSessionLocal

async def update_carpentry():
    async with AsyncSessionLocal() as session:
        # Update MainCategory
        await session.execute(text("UPDATE main_categories SET name = REPLACE(name, 'Carpentry Services', 'Modular Works & Interior Design') WHERE name ILIKE '%Carpentry%'"))
        
        # Update SubCategory
        await session.execute(text("UPDATE sub_categories SET name = REPLACE(name, 'Carpentry Services', 'Modular Works & Interior Design') WHERE name ILIKE '%Carpentry%'"))
            
        # Update Package
        await session.execute(text("UPDATE packages SET name = REPLACE(name, 'Carpentry Services', 'Modular Works & Interior Design') WHERE name ILIKE '%Carpentry%'"))
            
        await session.commit()
        print("Done!")

if __name__ == "__main__":
    asyncio.run(update_carpentry())
