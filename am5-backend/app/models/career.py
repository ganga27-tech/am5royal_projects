from datetime import datetime

from sqlalchemy import BigInteger, Boolean, Column, DateTime, ForeignKey, Integer, String, Text

from app.db.base_class import Base


class JobOpening(Base):
    __tablename__ = "job_openings"

    id = Column(BigInteger, primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    category = Column(String(50), nullable=False)  # Tech, Marketing, Operations, HR
    department = Column(String(100), nullable=False)
    employment_type = Column(String(100), nullable=False, default="Full-Time")
    location = Column(String(200), nullable=False)
    experience_years = Column(String(50), nullable=False, default="0-2 Years")
    description = Column(Text, nullable=False)
    key_skills = Column(Text, nullable=False, default="[]")  # JSON array string
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class JobApplication(Base):
    __tablename__ = "job_applications"

    id = Column(BigInteger, primary_key=True, index=True)
    application_reference = Column(String(30), unique=True, nullable=False, index=True)
    job_opening_id = Column(BigInteger, ForeignKey("job_openings.id"), nullable=False, index=True)
    full_name = Column(String(200), nullable=False)
    email = Column(String(200), nullable=False, index=True)
    phone = Column(String(20), nullable=False)
    current_location = Column(String(200), nullable=False)
    total_experience = Column(String(50), nullable=False)
    notice_period = Column(String(50), nullable=False)
    resume_url = Column(Text, nullable=False)
    resume_file_name = Column(String(255), nullable=False)
    resume_file_size = Column(Integer, nullable=False, default=0)
    cover_letter = Column(Text, nullable=True)
    status = Column(String(30), default="submitted", nullable=False)  # submitted, reviewed, shortlisted, rejected
    created_at = Column(DateTime, default=datetime.utcnow)
