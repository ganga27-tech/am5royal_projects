from sqlalchemy import Column, String, Integer, BigInteger, DateTime
from sqlalchemy.sql import func
from app.db.base_class import Base

class PointsHistory(Base):
    __tablename__ = "points_history"
    __mapper_args__ = {"exclude_properties": ["updated_at"]}

    id = Column(BigInteger, primary_key=True, index=True)
    user_id = Column(BigInteger, index=True)
    user_type = Column(String(50)) # 'employee', 'freelancer'
    points_added = Column(Integer)
    vendor_id = Column(BigInteger, nullable=True, index=True)
    reason = Column(String(255))
    created_at = Column(DateTime, server_default=func.now())
