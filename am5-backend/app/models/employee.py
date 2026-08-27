from sqlalchemy import Column, String, Integer, BigInteger, ForeignKey, DateTime, Float
from sqlalchemy.sql import func
from app.db.base_class import Base

class Employee(Base):
    __tablename__ = "employees"
    __mapper_args__ = {"exclude_properties": ["updated_at"]}

    id = Column(BigInteger, primary_key=True, index=True)
    first_name = Column(String)
    last_name = Column(String, nullable=True)
    email = Column(String, unique=True, index=True)
    phone_number = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    role = Column(String, default="telecaller")
    referral_points = Column(Integer, default=0)
    total_points = Column(Integer, default=0)
    status = Column(String, default="active")
    bank_name = Column(String, nullable=True)
    bank_account_number = Column(String, nullable=True)
    bank_account_name = Column(String, nullable=True)
    bank_ifsc_code = Column(String, nullable=True)

class WithdrawalRequest(Base):
    __tablename__ = "withdrawal_requests"

    id = Column(BigInteger, primary_key=True, index=True)
    employee_id = Column(BigInteger, ForeignKey("employees.id"), nullable=False)
    amount = Column(Float, nullable=False)
    status = Column(String, default="pending")  # "pending", "approved", "rejected"
    created_at = Column(DateTime, server_default=func.now())

    # Snapshot of bank details at time of withdrawal request
    bank_name = Column(String, nullable=True)
    bank_account_number = Column(String, nullable=True)
    bank_account_name = Column(String, nullable=True)
    bank_ifsc_code = Column(String, nullable=True)

