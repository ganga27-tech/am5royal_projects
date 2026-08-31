from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, EmailStr, Field


class JobOpeningPublic(BaseModel):
    id: int
    title: str
    category: str
    department: str
    employment_type: str
    location: str
    experience_years: str
    description: str
    key_skills: List[str]

    class Config:
        from_attributes = True


class JobOpeningAdmin(JobOpeningPublic):
    is_active: bool
    created_at: datetime
    updated_at: datetime


class JobOpeningCreate(BaseModel):
    title: str = Field(..., min_length=2, max_length=200)
    category: str = Field(..., min_length=2, max_length=50)
    department: str = Field(..., min_length=2, max_length=100)
    employment_type: str = Field(default="Full-Time", max_length=100)
    location: str = Field(..., min_length=2, max_length=200)
    experience_years: str = Field(default="0-2 Years", max_length=50)
    description: str = Field(..., min_length=3)
    key_skills: List[str] = Field(default_factory=list)
    is_active: bool = True


class JobOpeningUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=2, max_length=200)
    category: Optional[str] = Field(None, min_length=2, max_length=50)
    department: Optional[str] = Field(None, min_length=2, max_length=100)
    employment_type: Optional[str] = Field(None, max_length=100)
    location: Optional[str] = Field(None, min_length=2, max_length=200)
    experience_years: Optional[str] = Field(None, max_length=50)
    description: Optional[str] = Field(None, min_length=3)
    key_skills: Optional[List[str]] = None
    is_active: Optional[bool] = None


class ResumeUploadResponse(BaseModel):
    url: str
    file_name: str
    file_size: int


class JobApplicationCreate(BaseModel):
    job_opening_id: int
    full_name: str = Field(..., min_length=2, max_length=200)
    email: EmailStr
    phone: str = Field(..., min_length=10, max_length=15)
    current_location: str = Field(..., min_length=2, max_length=200)
    total_experience: str = Field(..., min_length=1, max_length=50)
    notice_period: str = Field(..., min_length=1, max_length=50)
    resume_url: str
    resume_file_name: str
    resume_file_size: int = Field(..., ge=1)
    cover_letter: Optional[str] = None


class JobApplicationPublicResponse(BaseModel):
    application_reference: str
    message: str = "Application submitted successfully"


class JobApplicationAdmin(BaseModel):
    id: int
    application_reference: str
    job_opening_id: int
    job_title: str
    job_category: str
    full_name: str
    email: str
    phone: str
    current_location: str
    total_experience: str
    notice_period: str
    resume_url: str
    resume_file_name: str
    resume_file_size: int
    cover_letter: Optional[str]
    status: str
    created_at: datetime

    class Config:
        from_attributes = True


class JobApplicationsPaginatedResponse(BaseModel):
    total: int
    items: List[JobApplicationAdmin]
