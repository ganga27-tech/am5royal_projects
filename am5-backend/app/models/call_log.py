from sqlalchemy import Column, String, BigInteger, ForeignKey, Text, Boolean
from app.db.base_class import Base

class TelecallerCallLog(Base):
    __tablename__ = "telecaller_call_logs"
    __mapper_args__ = {"exclude_properties": ["updated_at"]}

    id = Column(BigInteger, primary_key=True, index=True)
    telecaller_id = Column(BigInteger, ForeignKey("employees.id"), nullable=False, index=True)
    vendor_id = Column(BigInteger, ForeignKey("vendors.id"), nullable=True, index=True)
    target_phone = Column(String(20), nullable=False)
    agent_phone = Column(String(20), nullable=False)
    call_session_id = Column(String(100), nullable=True, index=True)
    record = Column(Boolean, default=True)
    recording_url = Column(Text, nullable=True)
    status = Column(String(50), default="initiated")  # "initiated", "failed"
    error_message = Column(Text, nullable=True)
