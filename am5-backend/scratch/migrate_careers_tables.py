"""Create career tables if they do not exist (safe for production)."""
import asyncio

from app.db.base_class import Base
from app.db.session import engine
from app.models.career import JobApplication, JobOpening


async def main() -> None:
    async with engine.begin() as conn:
        await conn.run_sync(
            Base.metadata.create_all,
            tables=[JobOpening.__table__, JobApplication.__table__],
        )
    print("Career tables ensured.")


if __name__ == "__main__":
    asyncio.run(main())
