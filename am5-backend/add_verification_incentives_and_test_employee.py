"""
Create verification_incentives table and ensure Test telecaller employee exists.

Usage (from am5-backend):
  python add_verification_incentives_and_test_employee.py

Keeps Mounika and Pratima untouched. Does NOT deactivate other telecallers
without manual review — prints active telecaller list for confirmation.
"""
import asyncio
from sqlalchemy import text, select
from app.db.session import AsyncSessionLocal, engine
from app.db.base_class import Base
from app.models.verification_incentive import VerificationIncentive
from app.models.employee import Employee
from app.core.security import get_password_hash


CREATE_TABLE_SQL = """
CREATE TABLE IF NOT EXISTS verification_incentives (
    id BIGSERIAL PRIMARY KEY,
    vendor_id BIGINT NOT NULL REFERENCES vendors(id),
    vendor_name VARCHAR(255) NOT NULL,
    subscription_amount DOUBLE PRECISION NOT NULL,
    incentive_percent DOUBLE PRECISION NOT NULL,
    incentive_amount DOUBLE PRECISION NOT NULL,
    payment_date TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    plan_id BIGINT NULL,
    employee_id BIGINT NULL REFERENCES employees(id),
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS ix_verification_incentives_vendor_id ON verification_incentives (vendor_id);
CREATE INDEX IF NOT EXISTS ix_verification_incentives_employee_id ON verification_incentives (employee_id);
CREATE INDEX IF NOT EXISTS ix_verification_incentives_id ON verification_incentives (id);
"""


async def main():
    async with engine.begin() as conn:
        await conn.execute(text(CREATE_TABLE_SQL))
        # Also register via metadata for non-Postgres if needed
        await conn.run_sync(Base.metadata.create_all)

    async with AsyncSessionLocal() as db:
        result = await db.execute(
            select(Employee).where(Employee.role == "telecaller").order_by(Employee.id)
        )
        employees = result.scalars().all()
        print("=== Active/all telecallers (review before deactivating duplicates) ===")
        for e in employees:
            print(
                f"id={e.id} name={e.first_name} {e.last_name or ''} "
                f"email={e.email} phone={e.phone_number} status={e.status}"
            )
            name_l = f"{e.first_name or ''} {e.last_name or ''}".lower()
            if "mounika" in name_l or "pratima" in name_l:
                print("  -> KEEP (protected by requirements)")

        # Create Test User (Dummy) if missing
        existing = await db.execute(
            select(Employee).where(
                (Employee.email == "test.telecaller@am5royal.com")
                | (Employee.phone_number == "9000000001")
            )
        )
        if existing.scalars().first():
            print("\nTest telecaller already exists.")
        else:
            test_emp = Employee(
                first_name="Test",
                last_name="User (Dummy)",
                email="test.telecaller@am5royal.com",
                phone_number="9000000001",
                hashed_password=get_password_hash("Test@1234"),
                role="telecaller",
                status="active",
            )
            db.add(test_emp)
            await db.commit()
            print("\nCreated Test User (Dummy) telecaller:")
            print("  email: test.telecaller@am5royal.com")
            print("  phone: 9000000001")
            print("  password: Test@1234")

    print("\nDone. verification_incentives table ready.")
    print("Do NOT auto-deactivate duplicates — confirm the list above first.")


if __name__ == "__main__":
    asyncio.run(main())
