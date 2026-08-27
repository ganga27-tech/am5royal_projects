from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.session import get_db
from app.models.engagement import Promotion as PromotionModel
from pydantic import BaseModel, ConfigDict
from decimal import Decimal
from datetime import date

# Schemas inside the file for speed, can be moved to schemas/ later
class FreePackage(BaseModel):
    packageName: str
    duration: int
    actualPrice: Decimal
    offeredPrice: Decimal

class Promotion(BaseModel):
    promotionId: int
    zoneId: Optional[int] = None
    zoneName: Optional[str] = None
    promotionName: str
    promotionType: str
    dealType: str
    startDate: date
    endDate: date
    status: str
    professionName: Optional[str] = None
    serviceName: Optional[str] = None
    packageName: Optional[str] = None
    duration: Optional[int] = None
    actualPrice: Optional[Decimal] = None
    offeredPrice: Optional[Decimal] = None
    freePackage: Optional[FreePackage] = None
    
    model_config = ConfigDict(from_attributes=True)

router = APIRouter()

@router.get("/promotions", response_model=List[Promotion])
async def get_promotions(
    db: AsyncSession = Depends(get_db),
    customerId: Optional[str] = Query(None),
    addressId: Optional[int] = Query(None),
    status: str = Query("active")
):
    """
    Get all active promotions and deals (Matches PDF Page 39).
    """
    query = select(PromotionModel).where(PromotionModel.status == status)
    
    # We could add zone-based filtering here using addressId
    
    result = await db.execute(query)
    promos = result.scalars().all()
    
    # Map model attributes to PDF-style camelCase response
    return [
        {
            "promotionId": p.id,
            "zoneId": p.zone_id,
            "zoneName": p.zone_name,
            "promotionName": p.name,
            "promotionType": p.promotion_type,
            "dealType": p.deal_type,
            "startDate": p.start_date,
            "endDate": p.end_date,
            "status": p.status,
            "professionName": p.profession_name,
            "serviceName": p.service_name,
            "packageName": p.package_name,
            "duration": p.duration,
            "actualPrice": p.actual_price,
            "offeredPrice": p.offered_price,
            "freePackage": p.free_package
        }
        for p in promos
    ]
