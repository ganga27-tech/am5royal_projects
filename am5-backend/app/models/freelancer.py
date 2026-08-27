from sqlalchemy import Column, String, Integer, BigInteger, DateTime
from sqlalchemy.sql import func
from app.db.base_class import Base

class Freelancer(Base):
    __tablename__ = "freelancers"
    __mapper_args__ = {"exclude_properties": ["updated_at"]}

    id = Column(BigInteger, primary_key=True, index=True)
    first_name = Column(String)
    last_name = Column(String, nullable=True)
    email = Column(String, unique=True, index=True)
    phone_number = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    referral_code = Column(String, unique=True, index=True)
    total_points = Column(Integer, default=0)
    status = Column(String, default="active")
    bank_name = Column(String, nullable=True)
    bank_account_number = Column(String, nullable=True)
    bank_account_name = Column(String, nullable=True)
    bank_ifsc_code = Column(String, nullable=True)
