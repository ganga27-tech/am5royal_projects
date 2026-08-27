from sqlalchemy import Column, String, Integer, Boolean, ForeignKey, Numeric, DateTime, Text, BigInteger, Date, JSON
from sqlalchemy.orm import relationship
from app.db.base_class import Base
import datetime

class City(Base):
    __tablename__ = "cities"

    id = Column(BigInteger, primary_key=True, index=True)
    code = Column(String)
    name = Column(String, nullable=False)
    state = Column(String)
    country = Column(String)
    boundary_geojson = Column(Text)
    timezone = Column(String)
    vendor_count = Column(Integer, default=0)
    active = Column(Boolean, default=True)
    tier = Column(String)
    tier_code = Column(Integer)
    pincodes = Column(Text)
    aliases = Column(JSON, nullable=True)
    latitude = Column(Numeric(9, 6), nullable=True)
    longitude = Column(Numeric(9, 6), nullable=True)
    state_code = Column(String)
    area_sq_km = Column(Numeric)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

class User(Base):
    __tablename__ = "users"

    id = Column(BigInteger, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    mobile = Column(String, unique=True, index=True)
    google_id = Column(String)
    auth_provider = Column(String)
    profile_picture = Column(Text)
    hashed_password = Column(String, nullable=True)
    otp_verified = Column(Boolean, default=False)
    role = Column(String, default="CUSTOMER")
    fcm_token = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)
    deletion_scheduled_at = Column(DateTime, nullable=True)

    customer = relationship("Customer", back_populates="user", uselist=False)

class Customer(Base):
    __tablename__ = "customers"

    id = Column(BigInteger, primary_key=True, index=True)
    user_id = Column(BigInteger, ForeignKey("users.id")) # Reference to auth user if needed
    full_name = Column(String, nullable=False)
    phone = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, index=True)
    profile_photo_url = Column(Text)
    loyalty_points = Column(Integer, default=0)
    total_bookings = Column(Integer, default=0)
    total_spent = Column(Numeric(10, 2), default=0.0)
    preferred_payment_method = Column(String)
    date_of_birth = Column(Date)
    gender = Column(String)
    alternate_phone = Column(String)
    deleted = Column(Boolean, default=False)
    version = Column(BigInteger, default=1)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    addresses = relationship("Address", back_populates="customer")
    user = relationship("User", back_populates="customer")

class Address(Base):
    __tablename__ = "customer_addresses"

    id = Column(BigInteger, primary_key=True, index=True)
    customer_id = Column(BigInteger, ForeignKey("customers.id"))
    label = Column(String) # e.g., Home, Work
    address_line1 = Column(String, nullable=False)
    address_line2 = Column(String)
    city = Column(String)
    state = Column(String)
    pincode = Column(String)
    latitude = Column(Numeric(10, 8))
    longitude = Column(Numeric(11, 8))
    is_default = Column(Boolean, default=False)
    deleted = Column(Boolean, default=False)
    version = Column(BigInteger, default=1)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    customer = relationship("Customer", back_populates="addresses")

class Zone(Base):
    __tablename__ = "zones" # Assuming this name for now based on PDF logic
    id = Column(Integer, primary_key=True, index=True)
    city_id = Column(BigInteger, ForeignKey("cities.id"))
    name = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
