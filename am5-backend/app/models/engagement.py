from sqlalchemy import Column, String, Integer, Boolean, ForeignKey, Text, JSON, Numeric, DateTime, BigInteger, Date
from sqlalchemy.orm import relationship
from app.db.base_class import Base
import datetime

class Promotion(Base):
    __tablename__ = "promotions"

    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(Text)
    promotion_type = Column(String) # WEEKLY, FESTIVE
    deal_type = Column(String) # getFree, percentage
    start_date = Column(Date)
    end_date = Column(Date)
    status = Column(String, default="active")
    
    # Target filters
    profession_name = Column(String)
    service_name = Column(String)
    package_name = Column(String)
    zone_id = Column(Integer)
    zone_name = Column(String)
    
    # Pricing
    duration = Column(Integer)
    actual_price = Column(Numeric(10, 2))
    offered_price = Column(Numeric(10, 2))
    
    # Free package details
    free_package = Column(JSON) 
    
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

class Banner(Base):
    __tablename__ = "banners"

    id = Column(BigInteger, primary_key=True, index=True)
    image_url = Column(String, nullable=False)
    city_id = Column(BigInteger, ForeignKey("cities.id"))
    link_url = Column(String)
    active = Column(Boolean, default=True)
    position = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

class FAQ(Base):
    __tablename__ = "faqs"

    id = Column(BigInteger, primary_key=True, index=True)
    question = Column(Text, nullable=False)
    answer = Column(Text, nullable=False)
    category = Column(String)
    package_id = Column(BigInteger, ForeignKey("packages.id"))
    active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

class Ticket(Base):
    __tablename__ = "support_tickets"

    id = Column(BigInteger, primary_key=True, index=True)
    ticket_number = Column(String, unique=True)
    user_id = Column(BigInteger)
    booking_id = Column(BigInteger)
    
    # Map title attribute to subject column in DB
    title = Column("subject", String, nullable=False)
    description = Column(Text, nullable=False)
    
    # Map ticket_type attribute to category column in DB
    ticket_type = Column("category", String, nullable=False)
    
    priority = Column(String, default="NORMAL")
    status = Column(String, default="OPEN")
    
    assigned_agent_id = Column(BigInteger)
    resolution_notes = Column(Text)
    
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)
    resolved_at = Column(DateTime)
    
    customer_id = Column(BigInteger, ForeignKey("customers.id"))
    customer_email = Column(String)
    customer_name = Column(String)
    assigned_agent = Column(String)
    
    message_count = Column(Integer, default=0)
    last_activity = Column(DateTime, default=datetime.datetime.utcnow)
    vendor_profile_id = Column(BigInteger)
    user_type = Column(String, default="CUSTOMER")

class Review(Base):
    __tablename__ = "reviews"
    id = Column(BigInteger, primary_key=True, index=True)
    customer_id = Column(BigInteger, ForeignKey("customers.id"))
    package_id = Column(BigInteger, ForeignKey("packages.id"))
    rating = Column(Numeric(2, 1))
    comment = Column(Text)
    is_verified = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

class Testimonial(Base):
    __tablename__ = "testimonials"
    id = Column(BigInteger, primary_key=True, index=True)
    customer_name = Column(String)
    content = Column(Text)
    image_url = Column(String)
    rating = Column(Integer)
    active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
