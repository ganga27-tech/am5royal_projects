from typing import List, Optional
from fastapi import APIRouter, Depends, File, UploadFile, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from app.db.session import get_db
from app.dependencies.auth import get_current_vendor
from app.models.vendor import Vendor
from app.models.vendor_extras import VendorSalesMedia, VendorOffer, VendorNewLaunch
from app.services.upload_service import upload_service
from pydantic import BaseModel, Field
from datetime import date, datetime

router = APIRouter()

# --- Pydantic Schemas ---
class SalesMediaResponse(BaseModel):
    id: int
    vendor_id: int
    media_type: str
    url: str
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

class OfferBase(BaseModel):
    title: str
    description: Optional[str] = None
    start_date: date
    end_date: date
    status: str = "active"
    images: List[str] = []

class OfferCreate(OfferBase):
    pass

class OfferUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    status: Optional[str] = None
    images: Optional[List[str]] = None

class OfferResponse(OfferBase):
    id: int
    vendor_id: int
    created_at: datetime

    class Config:
        from_attributes = True

class NewLaunchBase(BaseModel):
    details: str
    status: str = "active"
    images: List[str] = []

class NewLaunchCreate(NewLaunchBase):
    pass

class NewLaunchUpdate(BaseModel):
    details: Optional[str] = None
    status: Optional[str] = None
    images: Optional[List[str]] = None

class NewLaunchResponse(NewLaunchBase):
    id: int
    vendor_id: int
    created_at: datetime

    class Config:
        from_attributes = True

# --- Sales Media Endpoints ---
@router.get("/media", response_model=List[SalesMediaResponse])
async def get_sales_media(
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(VendorSalesMedia)
        .where(VendorSalesMedia.vendor_id == vendor.id, VendorSalesMedia.is_active == True)
        .order_by(VendorSalesMedia.created_at.desc())
    )
    return result.scalars().all()

@router.post("/media", response_model=SalesMediaResponse)
async def upload_sales_media(
    file: UploadFile = File(...),
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    filename = file.filename.lower()
    content_type = file.content_type.lower()
    
    # 1. Format validation
    is_image = content_type.startswith("image/") or any(filename.endswith(ext) for ext in [".jpg", ".jpeg", ".png", ".webp"])
    is_video = content_type.startswith("video/") or any(filename.endswith(ext) for ext in [".mp4", ".mov", ".avi"])
    
    if not (is_image or is_video):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid format. Allowed images: JPG, JPEG, PNG, WEBP. Allowed videos: MP4, MOV, AVI."
        )
    
    # Read contents to check size
    contents = await file.read()
    file_size = len(contents)
    
    # 2. Size validation
    if is_image and file_size > 10 * 1024 * 1024:  # 10 MB limit
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Image file size exceeds the 10MB limit."
        )
    if is_video and file_size > 100 * 1024 * 1024:  # 100 MB limit
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Video file size exceeds the 100MB limit."
        )
        
    # Upload to Cloudflare R2
    url = await upload_service.upload_file(contents, file.filename, file.content_type)
    if not url:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to upload file to storage."
        )
        
    media_type = "IMAGE" if is_image else "VIDEO"
    sales_media = VendorSalesMedia(
        vendor_id=vendor.id,
        media_type=media_type,
        url=url,
        is_active=True
    )
    db.add(sales_media)
    await db.commit()
    await db.refresh(sales_media)
    return sales_media

@router.delete("/media/{media_id}")
async def delete_sales_media(
    media_id: int,
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(VendorSalesMedia)
        .where(VendorSalesMedia.id == media_id, VendorSalesMedia.vendor_id == vendor.id)
    )
    media = result.scalar_one_or_none()
    if not media:
        raise HTTPException(status_code=404, detail="Media file not found")
        
    media.is_active = False
    db.add(media)
    await db.commit()
    return {"message": "Media deleted successfully"}


# --- Offers Endpoints ---
@router.get("/offers", response_model=List[OfferResponse])
async def get_offers(
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(VendorOffer)
        .where(VendorOffer.vendor_id == vendor.id)
        .order_by(VendorOffer.created_at.desc())
    )
    return result.scalars().all()

@router.post("/offers", response_model=OfferResponse)
async def create_offer(
    offer_in: OfferCreate,
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    offer = VendorOffer(
        vendor_id=vendor.id,
        title=offer_in.title,
        description=offer_in.description,
        start_date=offer_in.start_date,
        end_date=offer_in.end_date,
        status=offer_in.status,
        images=offer_in.images
    )
    db.add(offer)
    await db.commit()
    await db.refresh(offer)
    return offer

@router.put("/offers/{offer_id}", response_model=OfferResponse)
async def update_offer(
    offer_id: int,
    offer_in: OfferUpdate,
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(VendorOffer)
        .where(VendorOffer.id == offer_id, VendorOffer.vendor_id == vendor.id)
    )
    offer = result.scalar_one_or_none()
    if not offer:
        raise HTTPException(status_code=404, detail="Offer not found")
        
    update_data = offer_in.model_dump(exclude_unset=True)
    for field, val in update_data.items():
        setattr(offer, field, val)
        
    db.add(offer)
    await db.commit()
    await db.refresh(offer)
    return offer

@router.delete("/offers/{offer_id}")
async def delete_offer(
    offer_id: int,
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(VendorOffer)
        .where(VendorOffer.id == offer_id, VendorOffer.vendor_id == vendor.id)
    )
    offer = result.scalar_one_or_none()
    if not offer:
        raise HTTPException(status_code=404, detail="Offer not found")
        
    await db.delete(offer)
    await db.commit()
    return {"message": "Offer deleted successfully"}


# --- New Launches Endpoints ---
@router.get("/launches", response_model=List[NewLaunchResponse])
async def get_launches(
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(VendorNewLaunch)
        .where(VendorNewLaunch.vendor_id == vendor.id)
        .order_by(VendorNewLaunch.created_at.desc())
    )
    return result.scalars().all()

@router.post("/launches", response_model=NewLaunchResponse)
async def create_launch(
    launch_in: NewLaunchCreate,
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    launch = VendorNewLaunch(
        vendor_id=vendor.id,
        details=launch_in.details,
        status=launch_in.status,
        images=launch_in.images
    )
    db.add(launch)
    await db.commit()
    await db.refresh(launch)
    return launch

@router.put("/launches/{launch_id}", response_model=NewLaunchResponse)
async def update_launch(
    launch_id: int,
    launch_in: NewLaunchUpdate,
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(VendorNewLaunch)
        .where(VendorNewLaunch.id == launch_id, VendorNewLaunch.vendor_id == vendor.id)
    )
    launch = result.scalar_one_or_none()
    if not launch:
        raise HTTPException(status_code=404, detail="Launch not found")
        
    update_data = launch_in.model_dump(exclude_unset=True)
    for field, val in update_data.items():
        setattr(launch, field, val)
        
    db.add(launch)
    await db.commit()
    await db.refresh(launch)
    return launch

@router.delete("/launches/{launch_id}")
async def delete_launch(
    launch_id: int,
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(VendorNewLaunch)
        .where(VendorNewLaunch.id == launch_id, VendorNewLaunch.vendor_id == vendor.id)
    )
    launch = result.scalar_one_or_none()
    if not launch:
        raise HTTPException(status_code=404, detail="Launch not found")
        
    await db.delete(launch)
    await db.commit()
    return {"message": "Launch deleted successfully"}
