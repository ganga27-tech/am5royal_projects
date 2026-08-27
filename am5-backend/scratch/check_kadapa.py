import os
import sys
import asyncio
import asyncpg
from dotenv import load_dotenv

env_path = os.path.join(os.path.dirname(__file__), "..", ".env")
load_dotenv(env_path)

db_user = os.getenv("POSTGRES_USER")
db_pass = os.getenv("POSTGRES_PASSWORD")
db_host = os.getenv("POSTGRES_SERVER")
db_port = os.getenv("POSTGRES_PORT")
db_name = os.getenv("POSTGRES_DB")

async def main():
    conn = await asyncpg.connect(
        user=db_user,
        password=db_pass,
        host=db_host,
        port=db_port,
        database=db_name,
        timeout=10
    )

    rows = await conn.fetch("SELECT id, name, tier, aliases FROM cities WHERE LOWER(name) LIKE '%kadapa%' OR LOWER(name) LIKE '%cuddapah%' OR aliases::text ILIKE '%cuddapah%';")
    for r in rows:
        print(dict(r))

    await conn.close()

if __name__ == "__main__":
    asyncio.run(main())
