from fastapi import APIRouter, Depends, Header
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from pydantic import BaseModel
from typing import Optional
from datetime import datetime

from app.db.session import get_db
from app.models.device import DeviceInstallation
from app.models.user_location import User
from app.core.config import settings
from jose import jwt

router = APIRouter()

class DeviceSyncRequest(BaseModel):
    device_id: str
    device_model: Optional[str] = None
    os_version: Optional[str] = None
    app_version: Optional[str] = None
    fcm_token: Optional[str] = None

@router.post("/sync")
async def sync_device(
    payload: DeviceSyncRequest,
    db: AsyncSession = Depends(get_db),
    authorization: Optional[str] = Header(None)
):
    stmt = select(DeviceInstallation).where(DeviceInstallation.device_id == payload.device_id)
    result = await db.execute(stmt)
    device = result.scalars().first()

    if not device:
        device = DeviceInstallation(device_id=payload.device_id)
        db.add(device)

    device.device_model = payload.device_model
    device.os_version = payload.os_version
    device.app_version = payload.app_version
    device.fcm_token = payload.fcm_token
    device.last_active_at = datetime.utcnow()

    user_id = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization.split(" ")[1]
        try:
            payload_data = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
            if payload_data and "sub" in payload_data:
                user_id = int(payload_data["sub"])
        except Exception:
            pass # Invalid token, ignore user_id linking

    if user_id:
        device.user_id = user_id
        if payload.fcm_token:
            user_query = await db.execute(select(User).where(User.id == user_id))
            user = user_query.scalar_one_or_none()
            if user:
                user.fcm_token = payload.fcm_token
                db.add(user)

    await db.commit()
    return {"status": "success"}
