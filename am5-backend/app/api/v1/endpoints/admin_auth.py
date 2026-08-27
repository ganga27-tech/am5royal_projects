from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel

from app.db.session import get_db
from app.models.user_location import User
from app.core.security import verify_password, create_access_token
from app.schemas.auth import TokenResponse

router = APIRouter()

class AdminLoginRequest(BaseModel):
    email: str
    password: str

@router.post("/login", response_model=TokenResponse)
async def admin_login(
    request: AdminLoginRequest,
    db: AsyncSession = Depends(get_db)
):
    user_query = await db.execute(select(User).where(User.email == request.email))
    user = user_query.scalar_one_or_none()

    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    if "ADMIN" not in str(user.role):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied. Admin role required.")

    if not user.hashed_password:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    if not verify_password(request.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    access_token = create_access_token(subject=str(user.id))

    return TokenResponse(
        access_token=access_token,
        is_new_user=False
    )
