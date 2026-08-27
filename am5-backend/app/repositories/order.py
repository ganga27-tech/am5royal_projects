from app.repositories.base import BaseRepository
from app.models.orders import Order, OrderItem
from app.schemas.orders import OrderCreate, OrderUpdate
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload

class OrderRepository(BaseRepository[Order, OrderCreate, OrderUpdate]):
    async def get_with_items(self, db: AsyncSession, order_id: str) -> Order:
        query = select(self.model).options(
            selectinload(self.model.items)
        ).where(self.model.id == order_id)
        result = await db.execute(query)
        return result.scalar_one_or_none()

    async def get_by_customer(self, db: AsyncSession, customer_id: str) -> list[Order]:
        query = select(self.model).where(self.model.customer_id == customer_id).order_by(self.model.created_at.desc())
        result = await db.execute(query)
        return result.scalars().all()

order_repo = OrderRepository(Order)
