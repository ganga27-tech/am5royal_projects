from app.repositories.base import BaseRepository
from app.models.user_location import Customer
from app.schemas.user_location import CustomerCreate, CustomerUpdate
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

class CustomerRepository(BaseRepository[Customer, CustomerCreate, CustomerUpdate]):
    async def get_by_contact_number(self, db: AsyncSession, contact_number: str) -> Customer:
        query = select(self.model).where(self.model.contact_number == contact_number)
        result = await db.execute(query)
        return result.scalar_one_or_none()

    async def get_by_email(self, db: AsyncSession, email: str) -> Customer:
        query = select(self.model).where(self.model.email == email)
        result = await db.execute(query)
        return result.scalar_one_or_none()

customer_repo = CustomerRepository(Customer)
