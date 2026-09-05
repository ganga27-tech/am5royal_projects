from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import jwt
from app.core.config import settings
from app.db.session import get_db
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.user_location import Customer
from app.models.vendor import Vendor
from app.models.user_location import User
from app.services.security_service import security_service

reusable_oauth2 = HTTPBearer()



async def get_token(auth: HTTPAuthorizationCredentials = Depends(reusable_oauth2)) -> str:
    return auth.credentials

async def get_current_token_payload(token: str = Depends(get_token)) -> dict:
    # Check if token is blacklisted (Logout)
    if await security_service.is_token_blacklisted(token):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token is blacklisted",
        )

    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        return payload
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
        )

async def get_current_customer(
    db: AsyncSession = Depends(get_db),
    token: str = Depends(get_token)
) -> Customer:
    # Check if token is blacklisted (Logout)
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
        user_id = int(token_data)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid token format for customer access",
        )

    # JWT sub is users.id — resolve the linked customer row by user_id.
    query = select(Customer).where(Customer.user_id == user_id)
    result = await db.execute(query)
    customer = result.scalar_one_or_none()

    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")
    
    if customer.deleted:
        raise HTTPException(status_code=403, detail="Account deleted")
        
    return customer

async def get_current_vendor(
    db: AsyncSession = Depends(get_db),
    token: str = Depends(get_token)
) -> Vendor:
    # Check if token is blacklisted (Logout)
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
        user_id = int(token_data)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid token format for vendor access"
        )
        
    query = (
        select(Vendor, User.deletion_scheduled_at)
        .join(User, User.id == Vendor.user_id)
        .where(Vendor.user_id == user_id)
    )
    result = await db.execute(query)
    row = result.one_or_none()

    if not row:
        raise HTTPException(status_code=404, detail="Vendor not found for this user")

    vendor, deletion_scheduled_at = row[0], row[1]
    if deletion_scheduled_at:
        from datetime import datetime
        if deletion_scheduled_at <= datetime.utcnow():
            raise HTTPException(status_code=403, detail="Account deleted")

    allowed_statuses = {
        "active",
        "onboarding",
        "registration",
        "temporary_active",
        "draft",
        "approved",
        "pending",
        "verified",
        "in_review",
        "under_review",
        "slots",
        "payment",
        "subscription",
        "",
    }
    blocked_statuses = {
        "inactive",
        "suspended",
        "blocked",
        "banned",
        "rejected",
        "deleted",
        "deactivated",
    }
    vendor_status = (vendor.status or "").strip().lower().replace(" ", "_")
    if vendor_status in blocked_statuses or (vendor_status and vendor_status not in allowed_statuses):
        raise HTTPException(status_code=403, detail="Vendor account is not active")
        
    return vendor

async def get_current_admin(
    db: AsyncSession = Depends(get_db),
    token: str = Depends(get_token)
):
    from app.models.employee import Employee
    # Check if token is blacklisted (Logout)
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
        admin_id = int(token_data)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid token format"
        )
        
    query = select(Employee).where(Employee.id == admin_id)
    result = await db.execute(query)
    admin_user = result.scalar_one_or_none()
    
    if not admin_user:
        raise HTTPException(status_code=404, detail="Admin not found")
        
    if admin_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. Admin role required."
        )
        
    return admin_user

async def get_current_employee(
    db: AsyncSession = Depends(get_db),
    token: str = Depends(get_token)
):
    from app.models.employee import Employee
    # Check if token is blacklisted (Logout)
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
        raise HTTPException(status_code=404, detail="Employee not found")
        
    if employee.status != "active":
        raise HTTPException(status_code=403, detail="Employee account is not active")
        
    return employee
