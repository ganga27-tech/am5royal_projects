from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.dependencies.auth import get_current_admin
from app.models.career import JobApplication, JobOpening
from app.schemas.career import (
    JobApplicationAdmin,
    JobApplicationsPaginatedResponse,
    JobOpeningAdmin,
    JobOpeningCreate,
    JobOpeningUpdate,
)
from app.services.career_service import (
    opening_to_admin_dict,
    seed_default_openings_if_empty,
    skills_to_json,
)

router = APIRouter()


@router.get("/openings", response_model=list[JobOpeningAdmin])
async def admin_list_openings(
    db: AsyncSession = Depends(get_db),
    current_admin=Depends(get_current_admin),
):
    await seed_default_openings_if_empty(db)
    result = await db.execute(select(JobOpening).order_by(JobOpening.id.desc()))
    openings = result.scalars().all()
    return [opening_to_admin_dict(o) for o in openings]


@router.post("/openings", response_model=JobOpeningAdmin, status_code=status.HTTP_201_CREATED)
async def admin_create_opening(
    payload: JobOpeningCreate,
    db: AsyncSession = Depends(get_db),
    current_admin=Depends(get_current_admin),
):
    opening = JobOpening(
        title=payload.title.strip(),
        category=payload.category.strip(),
        department=payload.department.strip(),
        employment_type=payload.employment_type.strip(),
        location=payload.location.strip(),
        experience_years=payload.experience_years.strip(),
        description=payload.description.strip(),
        key_skills=skills_to_json(payload.key_skills),
        is_active=payload.is_active,
    )
    db.add(opening)
    await db.commit()
    await db.refresh(opening)
    return opening_to_admin_dict(opening)


@router.put("/openings/{opening_id}", response_model=JobOpeningAdmin)
async def admin_update_opening(
    opening_id: int,
    payload: JobOpeningUpdate,
    db: AsyncSession = Depends(get_db),
    current_admin=Depends(get_current_admin),
):
    result = await db.execute(select(JobOpening).where(JobOpening.id == opening_id))
    opening = result.scalar_one_or_none()
    if not opening:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Job opening not found")

    update_data = payload.model_dump(exclude_unset=True)
    if "key_skills" in update_data and update_data["key_skills"] is not None:
        update_data["key_skills"] = skills_to_json(update_data["key_skills"])

    for field, value in update_data.items():
        if isinstance(value, str):
            value = value.strip()
        setattr(opening, field, value)

    await db.commit()
    await db.refresh(opening)
    return opening_to_admin_dict(opening)


@router.delete("/openings/{opening_id}")
async def admin_deactivate_opening(
    opening_id: int,
    db: AsyncSession = Depends(get_db),
    current_admin=Depends(get_current_admin),
):
    result = await db.execute(select(JobOpening).where(JobOpening.id == opening_id))
    opening = result.scalar_one_or_none()
    if not opening:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Job opening not found")

    opening.is_active = False
    await db.commit()
    return {"message": "Job opening deactivated"}


@router.get("/applications", response_model=JobApplicationsPaginatedResponse)
async def admin_list_applications(
    job_opening_id: int | None = None,
    status_filter: str | None = None,
    search: str | None = None,
    skip: int = 0,
    limit: int = 20,
    db: AsyncSession = Depends(get_db),
    current_admin=Depends(get_current_admin),
):
    query = (
        select(JobApplication, JobOpening)
        .join(JobOpening, JobApplication.job_opening_id == JobOpening.id)
        .order_by(JobApplication.created_at.desc())
    )
    count_query = (
        select(func.count())
        .select_from(JobApplication)
        .join(JobOpening, JobApplication.job_opening_id == JobOpening.id)
    )

    if job_opening_id:
        query = query.where(JobApplication.job_opening_id == job_opening_id)
        count_query = count_query.where(JobApplication.job_opening_id == job_opening_id)

    if status_filter:
        query = query.where(JobApplication.status == status_filter)
        count_query = count_query.where(JobApplication.status == status_filter)

    if search:
        term = f"%{search.strip()}%"
        search_filter = or_(
            JobApplication.full_name.ilike(term),
            JobApplication.email.ilike(term),
            JobApplication.phone.ilike(term),
            JobApplication.application_reference.ilike(term),
            JobOpening.title.ilike(term),
        )
        query = query.where(search_filter)
        count_query = count_query.where(search_filter)

    total = await db.scalar(count_query) or 0
    result = await db.execute(query.offset(skip).limit(limit))
    rows = result.all()

    items = [
        JobApplicationAdmin(
            id=app.id,
            application_reference=app.application_reference,
            job_opening_id=app.job_opening_id,
            job_title=opening.title,
            job_category=opening.category,
            full_name=app.full_name,
            email=app.email,
            phone=app.phone,
            current_location=app.current_location,
            total_experience=app.total_experience,
            notice_period=app.notice_period,
            resume_url=app.resume_url,
            resume_file_name=app.resume_file_name,
            resume_file_size=app.resume_file_size,
            cover_letter=app.cover_letter,
            status=app.status,
            created_at=app.created_at,
        )
        for app, opening in rows
    ]
    return JobApplicationsPaginatedResponse(total=total, items=items)


@router.patch("/applications/{application_id}/status")
async def admin_update_application_status(
    application_id: int,
    status_value: str = Query(...),
    db: AsyncSession = Depends(get_db),
    current_admin=Depends(get_current_admin),
):
    allowed = {"submitted", "reviewed", "shortlisted", "rejected"}
    if status_value not in allowed:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid status")

    result = await db.execute(select(JobApplication).where(JobApplication.id == application_id))
    application = result.scalar_one_or_none()
    if not application:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Application not found")

    application.status = status_value
    await db.commit()
    return {"message": "Status updated", "status": status_value}
