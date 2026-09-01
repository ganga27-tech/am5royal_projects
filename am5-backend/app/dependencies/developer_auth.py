from fastapi import Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from jose import jwt

from app.core.config import settings
from app.db.session import get_db
from app.dependencies.auth import get_token
from app.models.employee import Employee
from app.services.security_service import security_service


async def get_current_dev_or_qa_user(
    db: AsyncSession = Depends(get_db),
    token: str = Depends(get_token)
) -> Employee:
    # Check if token is blacklisted
    if await security_service.is_token_blacklisted(token):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token is blacklisted",
        )

    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        token_data = payload.get("sub")
        if token_data is None:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Could not validate credentials",
            )
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Could not validate credentials",
        )

    try:
        employee_id = int(token_data)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid token format"
        )

    query = select(Employee).where(Employee.id == employee_id)
    result = await db.execute(query)
    employee = result.scalar_one_or_none()

    if not employee:
        raise HTTPException(status_code=404, detail="User not found")

    if employee.status != "active":
        raise HTTPException(status_code=403, detail="Employee account is not active")

    allowed_roles = ["developer", "qa", "admin", "super_admin"]
    if (employee.role or "").lower() not in allowed_roles:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Access denied. Required role in {allowed_roles}, got '{employee.role}'"
        )

    return employee


async def get_current_developer_user(
    current_user: Employee = Depends(get_current_dev_or_qa_user)
) -> Employee:
    if (current_user.role or "").lower() not in ["developer", "admin", "super_admin"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Developer role required"
        )
    return current_user


async def get_current_qa_user(
    current_user: Employee = Depends(get_current_dev_or_qa_user)
) -> Employee:
    if (current_user.role or "").lower() not in ["qa", "admin", "super_admin"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="QA role required"
        )
    return current_user


async def get_current_admin_user(
    current_user: Employee = Depends(get_current_dev_or_qa_user)
) -> Employee:
    if (current_user.role or "").lower() not in ["admin", "super_admin"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin role required"
        )
    return current_user
