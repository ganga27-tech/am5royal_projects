from sqlalchemy.ext.asyncio import AsyncSession
from app.repositories.order import order_repo
from app.models.orders import Order, OrderItem
from app.schemas.orders import OrderCreate
from app.repositories.catalog import package_repo # Assuming I create this
import uuid

class OrderService:
    async def create_order(self, db: AsyncSession, customer_id: str, order_in: OrderCreate) -> Order:
        # 1. Calculate totals
        total_amount = 0.0
        order_items_to_create = []
        
        for item in order_in.items:
            # In production, fetch actual price from DB
            # package = await package_repo.get(db, item.package_id)
            # unit_price = package.price
            unit_price = item.unit_price # Simplified for now
            total_item_price = unit_price * item.quantity
            total_amount += total_item_price
            
            order_items_to_create.append(OrderItem(
                package_id=item.package_id,
                sub_package_id=item.sub_package_id,
                quantity=item.quantity,
                unit_price=unit_price,
                total_price=total_item_price
            ))

        # 2. Apply discount / coupons (logic here)
        discount_amount = 0.0
        
        # 3. Calculate payable amount
        visiting_charge = 50.0 # Example
        tax_amount = total_amount * 0.18 # 18% GST example
        payable_amount = total_amount - discount_amount + tax_amount + visiting_charge + order_in.tip_amount - order_in.wallet_deduction

        # 4. Create Order
        db_order = Order(
            customer_id=customer_id,
            address_id=order_in.address_id,
            total_amount=total_amount,
            discount_amount=discount_amount,
            tax_amount=tax_amount,
            visiting_charge=visiting_charge,
            wallet_deduction=order_in.wallet_deduction,
            tip_amount=order_in.tip_amount,
            payable_amount=payable_amount,
            payment_method=order_in.payment_method,
            coupon_code=order_in.coupon_code,
            scheduled_at=order_in.scheduled_at,
            status="pending"
        )
        
        db.add(db_order)
        await db.flush() # Get order ID
        
        for item in order_items_to_create:
            item.order_id = db_order.id
            db.add(item)
            
        await db.commit()
        await db.refresh(db_order)
        return db_order

order_service = OrderService()
