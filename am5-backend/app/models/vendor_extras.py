from sqlalchemy import Column, String, Integer, Boolean, ForeignKey, Text, JSON, Numeric, DateTime, BigInteger, Date
from app.db.base_class import Base
from datetime import datetime

class VendorSalesMedia(Base):
    __tablename__ = "vendor_sales_media"

    id = Column(BigInteger, primary_key=True, index=True)
    vendor_id = Column(BigInteger, ForeignKey("vendors.id"), index=True)
    media_type = Column(String(50))  # IMAGE or VIDEO
    url = Column(Text, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class VendorOffer(Base):
    __tablename__ = "vendor_offers"

    id = Column(BigInteger, primary_key=True, index=True)
    vendor_id = Column(BigInteger, ForeignKey("vendors.id"), index=True)
    title = Column(String, nullable=False)
    description = Column(Text)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    status = Column(String(50), default="active")  # active, inactive, expired
    images = Column(JSON, default=[])  # JSON list of image URLs
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class VendorNewLaunch(Base):
    __tablename__ = "vendor_new_launches"

    id = Column(BigInteger, primary_key=True, index=True)
    vendor_id = Column(BigInteger, ForeignKey("vendors.id"), index=True)
    details = Column(Text, nullable=False)
    status = Column(String(50), default="active")
    images = Column(JSON, default=[])
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class VendorMonthlyHistory(Base):
    __tablename__ = "vendor_monthly_histories"

    id = Column(BigInteger, primary_key=True, index=True)
    vendor_id = Column(BigInteger, ForeignKey("vendors.id"), index=True)
    month = Column(String(10), nullable=False)  # format: YYYY-MM
    completed_services_count = Column(Integer, default=0)
    total_earnings = Column(Numeric(10, 2), default=0.0)
    created_at = Column(DateTime, default=datetime.utcnow)
