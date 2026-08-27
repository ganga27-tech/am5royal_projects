import asyncio
from app.db.session import AsyncSessionLocal
from sqlalchemy import text

async def main():
    async with AsyncSessionLocal() as session:
        try:
            # Sync sequence
            result = await session.execute(text(
                "SELECT setval(pg_get_serial_sequence('subscription_plans', 'id'), COALESCE(MAX(id), 1)) FROM subscription_plans;"
            ))
            new_val = result.scalar()
            await session.commit()
            print(f"Sequence synced successfully. New sequence value: {new_val}")
        except Exception as e:
            print(f"Error syncing sequence: {e}")
            await session.rollback()

if __name__ == "__main__":
    asyncio.run(main())
