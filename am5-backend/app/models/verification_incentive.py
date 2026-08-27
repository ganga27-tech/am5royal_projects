from sqlalchemy import Column, String, BigInteger, Float, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.db.base_class import Base


class VerificationIncentive(Base):
    __tablename__ = "verification_incentives"
    __mapper_args__ = {"exclude_properties": ["updated_at"]}

    id = Column(BigInteger, primary_key=True, index=True)
    vendor_id = Column(BigInteger, ForeignKey("vendors.id"), nullable=False, index=True)
    vendor_name = Column(String(255), nullable=False)
    subscription_amount = Column(Float, nullable=False)
    incentive_percent = Column(Float, nullable=False)
    incentive_amount = Column(Float, nullable=False)
    payment_date = Column(DateTime, nullable=False, server_default=func.now())
    plan_id = Column(BigInteger, nullable=True)
    employee_id = Column(BigInteger, ForeignKey("employees.id"), nullable=True, index=True)
    created_at = Column(DateTime, server_default=func.now())
