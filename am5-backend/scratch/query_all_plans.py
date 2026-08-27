import asyncio
import sys
import os

# Adjust path to import app modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

DATABASE_URL = "postgresql+asyncpg://am5royal_user:am5royal%4012345@76.13.245.174:5433/am5royal"

async def main():
    engine = create_async_engine(DATABASE_URL, echo=False)
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    
    async with async_session() as session:
        # Fetch all active subscription plans
        query = text("""
            SELECT id, name, price, original_price, validity_days, plan_type, tier, category_type, is_active
            FROM subscription_plans
            WHERE is_active = true
        """)
        result = await session.execute(query)
        plans = result.all()
        
        print("\n=== ALL ACTIVE PLANS ===")
        for p in plans:
            print(f"ID: {p[0]} | Name: {p[1]} | Price: {p[2]} | Orig: {p[3]} | Validity: {p[4]} days | Type: {p[5]} | Tier: {p[6]} | Category: {p[7]}")
            print("---")

if __name__ == "__main__":
    asyncio.run(main())
