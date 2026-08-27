from sqlalchemy import Column, String, ForeignKey, DateTime, BigInteger
from sqlalchemy.orm import relationship
from app.db.base_class import Base
import datetime

class DeviceInstallation(Base):
    __tablename__ = "device_installations"

    device_id = Column(String, primary_key=True, index=True)
    device_model = Column(String)
    os_version = Column(String)
    app_version = Column(String)
    fcm_token = Column(String, nullable=True)
    user_id = Column(BigInteger, ForeignKey("users.id"), nullable=True)
    installed_at = Column(DateTime, default=datetime.datetime.utcnow)
    last_active_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    user = relationship("User", backref="devices")
