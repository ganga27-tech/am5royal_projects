from sqlalchemy import Column, String, Integer, Boolean, ForeignKey, Numeric, DateTime, Text, BigInteger, Date, Time
from sqlalchemy.orm import relationship
from app.db.base_class import Base
import datetime

class Order(Base):
    __tablename__ = "bookings"

    id = Column(BigInteger, primary_key=True, index=True)
    booking_reference = Column(String, unique=True, index=True)
    customer_id = Column(BigInteger, ForeignKey("customers.id"))
    vendor_id = Column(BigInteger)
    vendor_profile_id = Column(BigInteger)
    service_id = Column(BigInteger)
    service_subcategory_id = Column(BigInteger)
    
    booking_date = Column(Date)
    booking_time = Column(Time)
    preferred_time_window = Column(String)
    service_address = Column("booking_address", Text)
    latitude = Column(Numeric)
    longitude = Column(Numeric)
    
    status = Column("booking_status", String, default="new")
    estimated_price = Column(Numeric(10, 2))
    total_amount = Column(Numeric(10, 2))
    final_amount = Column(Numeric(10, 2))
    
    special_instructions = Column(Text)
    customer_notes = Column(Text)
    vendor_notes = Column(Text)
    
    cancellation_reason = Column(Text)
    rejection_reason = Column(Text)
    cancelled_at = Column(DateTime)
    cancelled_by = Column(String)
    accepted_at = Column(DateTime)
    rejected_at = Column(DateTime)
    confirmed_at = Column(DateTime)
    
    start_otp = Column(String(10))
    end_otp = Column(String(10))
    started_at = Column(DateTime)
    completed_at = Column(DateTime)
    
    reschedule_count = Column(Integer, default=0)
    refunded_amount = Column(Numeric(10, 2))
    refund_reason = Column(Text)
    
    is_emergency = Column(Boolean, default=False)
    emergency_priority = Column(Integer)
    
    customer_name = Column(String)
    customer_phone = Column(String)
    customer_email = Column(String)
    
    vendor_name = Column(String)
    vendor_phone = Column(String)
    vendor_email = Column(String)
    vendor_address = Column(Text)
    
    service_name = Column(String)
    service_category = Column(String)
    service_description = Column(Text)
    duration_minutes = Column(Integer)
    
    service_location_id = Column(BigInteger)
    service_category_id = Column(BigInteger)
    city_tier = Column(String)
    
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    # Relationships
    items = relationship("OrderItem", back_populates="order")
    payments = relationship("Payment", back_populates="order")

class OrderItem(Base):
    __tablename__ = "order_items" # Keeping this as it's likely normalized even if not in 'bookings'
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(BigInteger, ForeignKey("bookings.id"))
    package_id = Column(BigInteger, ForeignKey("packages.id"))
    quantity = Column(Integer, default=1)
    price = Column(Numeric(10, 2))
    
    order = relationship("Order", back_populates="items")

class Payment(Base):
    __tablename__ = "payments"
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(BigInteger, ForeignKey("bookings.id"))
    amount = Column(Numeric(10, 2))
    status = Column(String) # pending, completed, failed
    provider = Column(String) # razorpay
    provider_payment_id = Column(String)
    provider_order_id = Column(String)
    
    order = relationship("Order", back_populates="payments")
