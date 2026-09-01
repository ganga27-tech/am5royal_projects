import asyncio
from sqlalchemy import text
from app.db.session import AsyncSessionLocal

async def main():
    async with AsyncSessionLocal() as db:
        print("Creating telecaller_call_logs table if not exists...")
        queries = [
            """
            CREATE TABLE IF NOT EXISTS telecaller_call_logs (
                id BIGSERIAL PRIMARY KEY,
                telecaller_id BIGINT NOT NULL REFERENCES employees(id),
                vendor_id BIGINT REFERENCES vendors(id),
                target_phone VARCHAR(20) NOT NULL,
                agent_phone VARCHAR(20) NOT NULL,
                call_session_id VARCHAR(100),
                record BOOLEAN DEFAULT TRUE,
                recording_url TEXT,
                status VARCHAR(50) DEFAULT 'initiated',
                error_message TEXT,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
            );
            """,
            "CREATE INDEX IF NOT EXISTS idx_telecaller_call_logs_telecaller_id ON telecaller_call_logs(telecaller_id);",
            "CREATE INDEX IF NOT EXISTS idx_telecaller_call_logs_vendor_id ON telecaller_call_logs(vendor_id);",
            "CREATE INDEX IF NOT EXISTS idx_telecaller_call_logs_call_session_id ON telecaller_call_logs(call_session_id);"
        ]
        try:
            for q in queries:
                await db.execute(text(q.strip()))
            await db.commit()
            print("Successfully created telecaller_call_logs table and indexes.")
        except Exception as e:
            print(f"Error creating table: {e}")

if __name__ == "__main__":
    asyncio.run(main())
