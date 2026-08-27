from sqlalchemy import Column, String, Integer, BigInteger, ForeignKey, Text, Numeric, DateTime, Boolean
from app.db.base_class import Base
from datetime import datetime

class MarketingLead(Base):
    __tablename__ = "marketing_leads"

    id = Column(BigInteger, primary_key=True, index=True)
    shop_name = Column(String)
    contact_person = Column(String)
    phone_number = Column(String)
    address = Column(Text)
    latitude = Column(Numeric(9, 6), nullable=True)
    longitude = Column(Numeric(9, 6), nullable=True)
    shop_image_url = Column(Text, nullable=True)
    notes = Column(Text, nullable=True)
    status = Column(String, default="NEW") # NEW, CONTACTED, ONBOARDED, REJECTED
    created_by_employee_id = Column(BigInteger, ForeignKey("employees.id"))
    assigned_to_employee_id = Column(BigInteger, ForeignKey("employees.id"), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class MarketingCollateral(Base):
    __tablename__ = "marketing_collaterals"

    id = Column(BigInteger, primary_key=True, index=True)
    title = Column(String)
    collateral_type = Column(String) # VIDEO, PDF, IMAGE, QR
    url = Column(Text)
    description = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
