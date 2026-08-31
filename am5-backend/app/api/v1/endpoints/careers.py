import os

from fastapi import APIRouter, Depends, File, HTTPException, Request, UploadFile, status
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.rate_limit import limiter
from app.db.session import get_db
from app.dependencies.auth import get_current_admin
from app.models.career import JobApplication, JobOpening
from app.schemas.career import (
    JobApplicationAdmin,
    JobApplicationCreate,
    JobApplicationPublicResponse,
    JobApplicationsPaginatedResponse,
    JobOpeningAdmin,
    JobOpeningCreate,
    JobOpeningPublic,
    JobOpeningUpdate,
    ResumeUploadResponse,
)
from app.services.career_service import (
    generate_application_reference,
    get_active_openings,
    get_opening_by_id,
    opening_to_admin_dict,
    opening_to_public_dict,
    seed_default_openings_if_empty,
    skills_to_json,
)
from app.services.upload_service import upload_service

router = APIRouter()

ALLOWED_RESUME_EXTENSIONS = {".pdf", ".doc", ".docx"}
ALLOWED_RESUME_CONTENT_TYPES = {
    "application/pdf",
    "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
}
MAX_RESUME_BYTES = 5 * 1024 * 1024


def _validate_resume_file(filename: str, content_type: str, size: int) -> None:
    ext = os.path.splitext(filename or "")[1].lower()
    if ext not in ALLOWED_RESUME_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Only PDF, DOC, and DOCX files are allowed",
        )
    if content_type and content_type not in ALLOWED_RESUME_CONTENT_TYPES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid resume file type",
        )
    if size > MAX_RESUME_BYTES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Resume must be 5MB or smaller",
        )


@router.get("/openings", response_model=list[JobOpeningPublic])
async def list_job_openings(db: AsyncSession = Depends(get_db)):
    await seed_default_openings_if_empty(db)
    openings = await get_active_openings(db)
    return [opening_to_public_dict(o) for o in openings]


@router.get("/openings/{opening_id}", response_model=JobOpeningPublic)
async def get_job_opening(opening_id: int, db: AsyncSession = Depends(get_db)):
    await seed_default_openings_if_empty(db)
    opening = await get_opening_by_id(db, opening_id, active_only=True)
    if not opening:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Job opening not found")
    return opening_to_public_dict(opening)


@router.post("/upload-resume", response_model=ResumeUploadResponse)
@limiter.limit("10/minute")
async def upload_resume(
    request: Request,
    file: UploadFile = File(...),
):
    filename = file.filename or "resume.pdf"
    content_type = file.content_type or "application/pdf"
    contents = await file.read()
    _validate_resume_file(filename, content_type, len(contents))

    url = await upload_service.upload_file(contents, filename, content_type)
    if not url:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to upload resume",
        )
    return ResumeUploadResponse(url=url, file_name=filename, file_size=len(contents))


@router.post("/applications", response_model=JobApplicationPublicResponse)
@limiter.limit("5/minute")
async def submit_job_application(
    request: Request,
    payload: JobApplicationCreate,
    db: AsyncSession = Depends(get_db),
):
    opening = await get_opening_by_id(db, payload.job_opening_id, active_only=True)
    if not opening:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Job opening not found")

    reference = await generate_application_reference(db)
    application = JobApplication(
        application_reference=reference,
        job_opening_id=payload.job_opening_id,
        full_name=payload.full_name.strip(),
        email=payload.email.strip().lower(),
        phone=payload.phone.strip(),
        current_location=payload.current_location.strip(),
        total_experience=payload.total_experience.strip(),
        notice_period=payload.notice_period.strip(),
        resume_url=payload.resume_url,
        resume_file_name=payload.resume_file_name,
        resume_file_size=payload.resume_file_size,
        cover_letter=(payload.cover_letter or "").strip() or None,
        status="submitted",
    )
    db.add(application)
    await db.commit()
    return JobApplicationPublicResponse(application_reference=reference)
