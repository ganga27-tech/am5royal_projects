import json
from datetime import datetime
from typing import List, Optional

from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.career import JobApplication, JobOpening

DEFAULT_OPENINGS = [
    {
        "title": "Backend Developer",
        "category": "Tech",
        "department": "Engineering",
        "employment_type": "Full-Time",
        "location": "Pan India (Remote / Hybrid)",
        "experience_years": "2-5 Years",
        "description": (
            "Build scalable APIs and microservices for AM5 ROYAL's service marketplace. "
            "Work with Python, FastAPI, PostgreSQL, and cloud infrastructure."
        ),
        "key_skills": ["Python", "FastAPI", "MySQL", "REST APIs", "Git", "Docker"],
    },
    {
        "title": "Frontend Developer",
        "category": "Tech",
        "department": "Engineering",
        "employment_type": "Full-Time",
        "location": "Pan India (Remote / Hybrid)",
        "experience_years": "2-5 Years",
        "description": (
            "Create beautiful, responsive web and mobile experiences using Flutter and modern web technologies."
        ),
        "key_skills": ["Flutter", "Dart", "JavaScript", "REST APIs", "Git", "UI/UX"],
    },
    {
        "title": "QA / Testing Engineer",
        "category": "Tech",
        "department": "Engineering",
        "employment_type": "Full-Time",
        "location": "Pan India (Remote / Hybrid)",
        "experience_years": "1-3 Years",
        "description": (
            "Ensure quality across web, mobile, and API products through manual and automated testing."
        ),
        "key_skills": ["Manual Testing", "API Testing", "Postman", "Jira", "Regression Testing"],
    },
    {
        "title": "Digital Marketing Executive",
        "category": "Marketing",
        "department": "Marketing",
        "employment_type": "Full-Time",
        "location": "Pan India (Remote / Hybrid)",
        "experience_years": "1-3 Years",
        "description": (
            "Drive brand growth through SEO, social media, paid campaigns, and content marketing."
        ),
        "key_skills": ["SEO", "Social Media", "Google Ads", "Content Writing", "Analytics"],
    },
    {
        "title": "Vendor Verification Executive",
        "category": "Operations",
        "department": "Operations",
        "employment_type": "Full-Time · Multiple Languages",
        "location": "Pan India",
        "experience_years": "1-3 Years",
        "description": (
            "Verify vendor documents, conduct field visits, and ensure onboarding quality standards."
        ),
        "key_skills": ["Field Verification", "Documentation", "Communication", "Hindi", "English"],
    },
    {
        "title": "HR Executive",
        "category": "HR",
        "department": "Human Resources",
        "employment_type": "Full-Time",
        "location": "Pan India (Remote / Hybrid)",
        "experience_years": "2-4 Years",
        "description": (
            "Manage recruitment, employee onboarding, and HR operations for a fast-growing startup."
        ),
        "key_skills": ["Recruitment", "HR Operations", "Interviewing", "Payroll", "Compliance"],
    },
]


def skills_to_list(raw: str) -> List[str]:
    try:
        parsed = json.loads(raw or "[]")
        if isinstance(parsed, list):
            return [str(s) for s in parsed]
    except json.JSONDecodeError:
        pass
    return []


def skills_to_json(skills: List[str]) -> str:
    return json.dumps(skills or [])


def opening_to_public_dict(opening: JobOpening) -> dict:
    return {
        "id": opening.id,
        "title": opening.title,
        "category": opening.category,
        "department": opening.department,
        "employment_type": opening.employment_type,
        "location": opening.location,
        "experience_years": opening.experience_years,
        "description": opening.description,
        "key_skills": skills_to_list(opening.key_skills),
    }


def opening_to_admin_dict(opening: JobOpening) -> dict:
    data = opening_to_public_dict(opening)
    data.update(
        {
            "is_active": opening.is_active,
            "created_at": opening.created_at,
            "updated_at": opening.updated_at,
        }
    )
    return data


async def seed_default_openings_if_empty(db: AsyncSession) -> None:
    count = await db.scalar(select(func.count()).select_from(JobOpening))
    if count and count > 0:
        return

    for item in DEFAULT_OPENINGS:
        db.add(
            JobOpening(
                title=item["title"],
                category=item["category"],
                department=item["department"],
                employment_type=item["employment_type"],
                location=item["location"],
                experience_years=item["experience_years"],
                description=item["description"],
                key_skills=skills_to_json(item["key_skills"]),
                is_active=True,
            )
        )
    await db.commit()


async def generate_application_reference(db: AsyncSession) -> str:
    year = datetime.utcnow().year
    prefix = f"APP-{year}-"
    result = await db.execute(
        select(func.max(JobApplication.id))
    )
    max_id = result.scalar() or 0
    return f"{prefix}{max_id + 1:07d}"


async def get_active_openings(db: AsyncSession) -> List[JobOpening]:
    result = await db.execute(
        select(JobOpening)
        .where(JobOpening.is_active.is_(True))
        .order_by(JobOpening.id.asc())
    )
    return list(result.scalars().all())


async def get_opening_by_id(db: AsyncSession, opening_id: int, active_only: bool = True) -> Optional[JobOpening]:
    query = select(JobOpening).where(JobOpening.id == opening_id)
    if active_only:
        query = query.where(JobOpening.is_active.is_(True))
    result = await db.execute(query)
    return result.scalar_one_or_none()
