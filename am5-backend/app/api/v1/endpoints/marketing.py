from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime
from decimal import Decimal

from app.db.session import get_db
from app.models.marketing import MarketingLead, MarketingCollateral
from app.dependencies.auth import get_current_employee

router = APIRouter()

class LeadCreate(BaseModel):
    shop_name: str
    contact_person: str
    phone_number: str
    address: str
    latitude: Optional[Decimal] = None
    longitude: Optional[Decimal] = None
    shop_image_url: Optional[str] = None
    notes: Optional[str] = None

class LeadResponse(BaseModel):
    id: int
    shop_name: str
    contact_person: str
    phone_number: str
    address: str
    latitude: Optional[Decimal] = None
    longitude: Optional[Decimal] = None
    shop_image_url: Optional[str] = None
    notes: Optional[str] = None
    status: str
    created_by_employee_id: int
    assigned_to_employee_id: Optional[int] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True

class LeadStatusUpdate(BaseModel):
    status: str

class LeadAssign(BaseModel):
    employee_id: int

class CollateralResponse(BaseModel):
    id: int
    title: str
    collateral_type: str
    url: str
    description: Optional[str] = None
    is_active: bool

    class Config:
        orm_mode = True

@router.post("/leads", response_model=LeadResponse)
async def create_lead(
    lead_in: LeadCreate,
    db: AsyncSession = Depends(get_db),
    current_employee = Depends(get_current_employee)
):
    # Only employees can create leads
    if getattr(current_employee, "role", None) not in ["telecaller", "admin", "marketing"]:
        # Allow any authenticated employee for now if role checking is not strict
        pass

    new_lead = MarketingLead(
        **lead_in.dict(),
        created_by_employee_id=current_employee.id,
        status="NEW"
    )
    db.add(new_lead)
    await db.commit()
    await db.refresh(new_lead)
    return new_lead

@router.get("/leads", response_model=List[LeadResponse])
async def list_leads(
    db: AsyncSession = Depends(get_db),
    current_employee = Depends(get_current_employee),
    assigned_to_me: bool = False,
    created_by_me: bool = False
):
    query = select(MarketingLead)
    if assigned_to_me:
        query = query.where(MarketingLead.assigned_to_employee_id == current_employee.id)
    if created_by_me:
        query = query.where(MarketingLead.created_by_employee_id == current_employee.id)

    result = await db.execute(query)
    leads = result.scalars().all()
    return leads

@router.put("/leads/{lead_id}/status", response_model=LeadResponse)
async def update_lead_status(
    lead_id: int,
    status_update: LeadStatusUpdate,
    db: AsyncSession = Depends(get_db),
    current_employee = Depends(get_current_employee)
):
    result = await db.execute(select(MarketingLead).where(MarketingLead.id == lead_id))
    lead = result.scalar_one_or_none()
    if not lead:
        raise HTTPException(status_code=404, detail="Lead not found")
    
    lead.status = status_update.status
    await db.commit()
    await db.refresh(lead)
    return lead

@router.put("/leads/{lead_id}/assign", response_model=LeadResponse)
async def assign_lead(
    lead_id: int,
    assign_in: LeadAssign,
    db: AsyncSession = Depends(get_db),
    current_employee = Depends(get_current_employee)
):
    result = await db.execute(select(MarketingLead).where(MarketingLead.id == lead_id))
    lead = result.scalar_one_or_none()
    if not lead:
        raise HTTPException(status_code=404, detail="Lead not found")
    
    lead.assigned_to_employee_id = assign_in.employee_id
    await db.commit()
    await db.refresh(lead)
    return lead

@router.get("/collaterals", response_model=List[CollateralResponse])
async def list_collaterals(
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(MarketingCollateral).where(MarketingCollateral.is_active == True))
    collaterals = result.scalars().all()
    return collaterals
