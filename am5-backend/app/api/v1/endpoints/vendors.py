from typing import List, Optional
from fastapi import APIRouter, Depends, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.db.session import get_db
from app.models.vendor import Vendor, VendorSubCategory, VendorAvailability, VendorService, VendorServiceMedia
from app.models.catalog import ServiceCategory, ServiceSubcategory, Service
from app.services.otp_service import otp_service
from app.schemas.vendor import (
    VendorLocationResponse, 
    VendorAvailabilityCreate, 
    VendorAvailabilityListResponse,
    VendorProfileResponse,
    VendorProfileUpdate
)
from app.schemas.vendor_registration import VendorBusinessDetailsRequest, VendorBusinessDetailsResponse
from app.models.vendor import VendorDocument
from fastapi import HTTPException
from sqlalchemy import delete
from app.dependencies.auth import get_current_vendor
from app.models.subscriptions import VendorSubscription
from app.schemas.vendor_catalog import (
    VendorCategoryAddRequest,
    VendorCatalogResponse,
    VendorCatalogMainCategoryGroup,
    VendorCatalogSubCategoryGroup,
    VendorCatalogServiceItem,
    MediaItem,
)
from app.models.user_location import User

router = APIRouter()

_VENDOR_PROFILE_UPDATE_FIELDS = {
    "first_name",
    "last_name",
    "father_name",
    "email",
    "alternative_number",
    "business_name",
    "address",
    "street",
    "city",
    "district",
    "state",
    "pincode",
    "latitude",
    "longitude",
    "profile_image",
    "background_banner",
    "business_description",
    "business_highlights",
    "about_business",
    "alternative_contact_number",
}


def _normalize_business_highlights(value) -> Optional[List[str]]:
    if value is None:
        return None
    if isinstance(value, list):
        return [str(item) for item in value]
    return None


def _build_vendor_profile_response(
    vendor: Vendor, user: Optional[User]
) -> VendorProfileResponse:
    vendor_email = getattr(vendor, "email", None)
    user_email = user.email if user else None
    
    effective_email = None
    if vendor_email and not vendor_email.startswith("vendor_"):
        effective_email = vendor_email
    elif user_email and not user_email.startswith("vendor_"):
        effective_email = user_email
    else:
        effective_email = vendor_email or user_email

    return VendorProfileResponse(
        id=int(vendor.id),
        user_id=int(vendor.user_id),
        mobile=user.mobile if user else None,
        email=effective_email,
        first_name=vendor.first_name,
        last_name=vendor.last_name,
        father_name=vendor.father_name,
        business_name=vendor.business_name,
        address=vendor.address,
        street=getattr(vendor, "street", None),
        city=vendor.city,
        district=getattr(vendor, "district", None),
        state=vendor.state,
        pincode=vendor.pincode,
        latitude=float(vendor.latitude) if vendor.latitude is not None else None,
        longitude=float(vendor.longitude) if vendor.longitude is not None else None,
        profile_image=vendor.profile_image,
        background_banner=getattr(vendor, "background_banner", None),
        business_description=getattr(vendor, "business_description", None),
        business_highlights=_normalize_business_highlights(
            getattr(vendor, "business_highlights", None)
        ),
        about_business=getattr(vendor, "about_business", None),
        additional_business_info=getattr(vendor, "additional_business_info", None),
        alternative_contact_number=getattr(
            vendor, "alternative_contact_number", None
        ),
        status=vendor.status,
    )

@router.get("/locations", response_model=List[VendorLocationResponse])
async def get_vendor_locations(db: AsyncSession = Depends(get_db)):
    """
    Fetches the list of all active vendors across India.
    Returns: Latitude, Longitude, and their corresponding Main Category Icon/Image.
    """
    query = (
        select(Vendor, ServiceCategory.icon)
        .outerjoin(VendorSubCategory, Vendor.id == VendorSubCategory.vendor_id)
        .outerjoin(ServiceCategory, VendorSubCategory.main_category_id == ServiceCategory.id)
        .where(
            Vendor.status == "active",
            Vendor.latitude.is_not(None),
            Vendor.longitude.is_not(None)
        )
        .distinct(Vendor.id)
    )
    
    result = await db.execute(query)
    
    response = []
    # Using fetchall because the query returns a tuple of (Vendor, icon_url)
    for row in result.fetchall():
        vendor = row[0]
        icon_url = row[1]
        
        response.append(
            VendorLocationResponse(
                vendor_id=vendor.id,
                latitude=float(vendor.latitude),
                longitude=float(vendor.longitude),
                icon_url=icon_url
            )
        )
        
    return response

@router.get("/me/onboarding-status")
async def get_onboarding_status(
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    """
    Returns the onboarding status of the vendor.
    Provides flags for each completed step so the frontend can route accordingly.
    Read-only: must not trigger SMS, push notifications, or any side effects.
    """
    from sqlalchemy import text

    vendor_id = vendor.id
    is_telecaller_onboarded = vendor.onboarded_by_employee_id is not None

    # Single round-trip: all step flags via EXISTS (index-friendly on vendor_id)
    flags_result = await db.execute(
        text("""
            SELECT
                EXISTS(
                    SELECT 1 FROM vendor_services
                    WHERE vendor_id = :vendor_id
                ) AS services_added,
                EXISTS(
                    SELECT 1 FROM vendor_availability
                    WHERE vendor_id = :vendor_id
                ) AS availability_added,
                EXISTS(
                    SELECT 1 FROM vendor_subscriptions
                    WHERE vendor_id = :vendor_id AND status = 'active'
                ) AS subscription_done,
                EXISTS(
                    SELECT 1 FROM vendor_documents
                    WHERE vendor_id = :vendor_id
                ) AS business_registration_done
        """),
        {"vendor_id": vendor_id},
    )
    flags = flags_result.one()

    if is_telecaller_onboarded:
        registration_done = vendor.status == "active"
    else:
        registration_done = vendor.status == "active" or (
            vendor.first_name is not None and vendor.business_name is not None
        )

    return {
        "status": vendor.status,
        "otp_verified": True,
        "registration_done": registration_done,
        "services_added": bool(flags.services_added),
        "availability_added": bool(flags.availability_added),
        "business_registration_done": bool(flags.business_registration_done),
        "subscription": bool(flags.subscription_done),
        "is_telecaller_onboarded": is_telecaller_onboarded,
        "telecaller_services_updated": vendor.telecaller_services_updated if is_telecaller_onboarded else False,
    }

async def _vendor_kyc_is_locked(db: AsyncSession, vendor_id: int) -> bool:
    # Allow modifications/updates so vendors can edit or re-upload documents
    return False


@router.post("/me/business-details")
async def update_business_details(
    request: VendorBusinessDetailsRequest,
    background_tasks: BackgroundTasks,
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    """
    Updates the business details of the vendor and saves uploaded documents.
    """
    if request.gst_number is not None:
        vendor.gst_number = request.gst_number
    if request.pan_number is not None:
        vendor.pan_number = request.pan_number
    if request.usc_number is not None:
        vendor.usc_number = request.usc_number
    if request.aadhaar_number is not None:
        vendor.aadhaar_number = request.aadhaar_number
    if request.msme_number is not None:
        vendor.msme_number = request.msme_number
    if request.govt_auth_doc_number is not None:
        vendor.govt_auth_doc_number = request.govt_auth_doc_number
    if request.current_bill_number is not None:
        vendor.current_bill_number = request.current_bill_number
        
    db.add(vendor)

    if request.documents:
        from sqlalchemy import delete
        for doc in request.documents:
            # Delete existing documents of the same type to override with latest file
            await db.execute(
                delete(VendorDocument).where(
                    VendorDocument.vendor_id == vendor.id,
                    VendorDocument.document_type == doc.document_type
                )
            )
            new_doc = VendorDocument(
                vendor_id=vendor.id,
                document_type=doc.document_type,
                document_url=doc.document_url,
                verification_status="pending"
            )
            db.add(new_doc)

        active_sub = (
            await db.execute(
                select(VendorSubscription).where(
                    VendorSubscription.vendor_id == vendor.id,
                    VendorSubscription.status == "active",
                )
            )
        ).scalar_one_or_none()

        if not active_sub:
            user_query = await db.execute(select(User).where(User.id == vendor.user_id))
            user = user_query.scalar_one_or_none()
            if user:
                if user.mobile:
                    tpid_pay = "1707178343913056161"
                    msg_pay = "Welcome to AM5 Royal! Your documents have been submitted successfully. Only one step is left. Please complete your premium payment to activate your AM5Royal vendor account and start receiving customer leads thgrough click on this link https://vendor.am5royal.com/login"
                    background_tasks.add_task(otp_service.send_custom_sms, phone=user.mobile, message=msg_pay, tpid=tpid_pay)

                from app.services.notification_service import send_user_push_notification
                background_tasks.add_task(
                    send_user_push_notification,
                    user_id=user.id,
                    title="Complete Your Payment",
                    body="Last step to complete the payment and active your account.",
                )
            
    await db.commit()
    
    return {"message": "Business details updated successfully"}


@router.get("/me/business-details", response_model=VendorBusinessDetailsResponse)
async def get_business_details(
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db),
):
    """Returns saved business identity fields and uploaded document URLs for edit/prefill."""
    docs_result = await db.execute(
        select(VendorDocument).where(VendorDocument.vendor_id == vendor.id)
    )
    documents = [
        {"document_type": doc.document_type, "document_url": doc.document_url}
        for doc in docs_result.scalars().all()
    ]
    return VendorBusinessDetailsResponse(
        gst_number=vendor.gst_number,
        pan_number=vendor.pan_number,
        usc_number=vendor.usc_number,
        aadhaar_number=vendor.aadhaar_number,
        msme_number=vendor.msme_number,
        govt_auth_doc_number=vendor.govt_auth_doc_number,
        current_bill_number=vendor.current_bill_number,
        documents=documents,
        kyc_locked=len(documents) > 0,
    )

@router.get("/me/availability", response_model=VendorAvailabilityListResponse)
async def get_vendor_availability(
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    """
    Fetches the availability timings for the currently authenticated vendor.
    """
    vendor_id = vendor.id
    query = select(VendorAvailability).where(VendorAvailability.vendor_id == vendor_id)
    result = await db.execute(query)
    availabilities = result.scalars().all()
    return VendorAvailabilityListResponse(availabilities=availabilities)

@router.put("/me/availability", response_model=VendorAvailabilityListResponse)
async def update_vendor_availability(
    availabilities: List[VendorAvailabilityCreate],
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    """
    Updates the availability timings for the currently authenticated vendor.
    """
    vendor_id = vendor.id
    
    # Delete existing
    delete_query = delete(VendorAvailability).where(VendorAvailability.vendor_id == vendor_id)
    await db.execute(delete_query)
    
    # Insert new
    new_records = []
    for avail in availabilities:
        new_record = VendorAvailability(
            vendor_id=vendor_id,
            day_of_week=avail.day_of_week,
            start_time=avail.start_time,
            end_time=avail.end_time,
            is_available=avail.is_available
        )
        db.add(new_record)
        new_records.append(new_record)
        
    await db.commit()
    
    for record in new_records:
        await db.refresh(record)
        
    return VendorAvailabilityListResponse(availabilities=new_records)

@router.get("/me/profile", response_model=VendorProfileResponse)
async def get_vendor_profile(
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    """
    Fetches the vendor's profile details including their read-only mobile number.
    """
    # Fetch user to get mobile and email
    user_query = await db.execute(select(User).where(User.id == vendor.user_id))
    user = user_query.scalar_one_or_none()
    
    return _build_vendor_profile_response(vendor, user)

@router.put("/me/profile", response_model=VendorProfileResponse)
async def update_vendor_profile(
    request: VendorProfileUpdate,
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    """
    Updates the vendor's profile details. Excludes mobile number modification.
    """
    update_data = request.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        if key in _VENDOR_PROFILE_UPDATE_FIELDS:
            setattr(vendor, key, value)

    user_query = await db.execute(select(User).where(User.id == vendor.user_id))
    user = user_query.scalar_one_or_none()
    req_email = getattr(request, "email", None)
    if user and req_email and user.email != req_email:
        existing_email_user = (await db.execute(
            select(User.id).where(User.email == req_email, User.id != user.id)
        )).scalar_one_or_none()
        if not existing_email_user:
            user.email = req_email
            db.add(user)

    db.add(vendor)
    await db.commit()

    return _build_vendor_profile_response(vendor, user)

from datetime import datetime, timedelta

@router.delete("/me/profile")
async def delete_vendor_profile(
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    """
    Schedules the vendor's account for deletion.
    If the user does not log back in within 30 days, the account is permanently soft-deleted.
    """
    user_query = await db.execute(select(User).where(User.id == vendor.user_id))
    user = user_query.scalar_one_or_none()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    user.deletion_scheduled_at = datetime.utcnow() + timedelta(days=30)
    db.add(user)
    await db.commit()
    
    return {"message": "Account scheduled for deletion in 30 days."}


from pydantic import BaseModel
from typing import Optional, List

class MediaItemUpdate(BaseModel):
    media_url: str
    media_type: str  # 'image' or 'video'

class VendorServiceUpdateRequest(BaseModel):
    price: float
    description: Optional[str] = None
    negotiable: bool = False
    media: Optional[List[MediaItemUpdate]] = []

@router.get("/me/services")
async def get_my_services(
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    """
    Get all services for the logged-in vendor.
    """
    query = select(VendorService).where(VendorService.vendor_id == vendor.id)
    res = await db.execute(query)
    services = res.scalars().all()
    
    output = []
    for service in services:
        media_query = select(VendorServiceMedia).where(VendorServiceMedia.vendor_service_id == service.id)
        media_res = await db.execute(media_query)
        media_items = media_res.scalars().all()
        
        sub_cat_query = select(ServiceSubcategory).where(ServiceSubcategory.id == service.sub_category_id)
        sub_cat_res = await db.execute(sub_cat_query)
        sub_cat = sub_cat_res.scalar_one_or_none()
        sub_category_name = sub_cat.name if sub_cat else "Unknown"

        cat_service_query = select(Service).where(Service.id == service.service_id)
        cat_service_res = await db.execute(cat_service_query)
        cat_service = cat_service_res.scalar_one_or_none()
        image_url = cat_service.image_url if cat_service else None
        
        output.append({
            "id": service.id,
            "service_id": service.service_id,
            "title": service.title,
            "description": service.description,
            "price": float(service.price) if service.price else 0.0,
            "discounted_price": float(service.discounted_price) if service.discounted_price else None,
            "negotiable": service.negotiable,
            "main_category_id": service.main_category_id,
            "sub_category_id": service.sub_category_id,
            "sub_category_name": sub_category_name,
            "is_active": service.is_active,
            "image_url": image_url,
            "media": [{"media_url": m.media_url, "media_type": m.media_type} for m in media_items]
        })
        
    return output

@router.put("/me/services/{vendor_service_id}")
async def update_vendor_service(
    vendor_service_id: int,
    request: VendorServiceUpdateRequest,
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    """
    Updates price, description, negotiable, and media of a specific vendor service.
    """
    query = select(VendorService).where(
        VendorService.id == vendor_service_id,
        VendorService.vendor_id == vendor.id
    )
    res = await db.execute(query)
    vendor_service = res.scalar_one_or_none()
    
    if not vendor_service:
        raise HTTPException(status_code=404, detail="Vendor service not found")
        
    vendor_service.price = request.price
    vendor_service.description = request.description
    vendor_service.negotiable = request.negotiable
    
    db.add(vendor_service)
    
    from sqlalchemy import delete
    await db.execute(delete(VendorServiceMedia).where(VendorServiceMedia.vendor_service_id == vendor_service_id))
    
    if request.media:
        for m in request.media:
            new_media = VendorServiceMedia(
                vendor_service_id=vendor_service_id,
                media_type=m.media_type,
                media_url=m.media_url
            )
            db.add(new_media)
            
    await db.commit()
    return {"message": "Service updated successfully"}


@router.get("/me/catalog", response_model=VendorCatalogResponse)
async def get_vendor_catalog(
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db),
):
    """Returns vendor catalog grouped by main category → subcategory → services."""
    active_subscription = (
        await db.execute(
            select(VendorSubscription.id).where(
                VendorSubscription.vendor_id == vendor.id,
                VendorSubscription.status == "active",
            ).limit(1)
        )
    ).scalar_one_or_none()

    if not active_subscription:
        return VendorCatalogResponse(
            categories=[],
            total_services=0,
            total_active_services=0,
        )

    subcat_rows = (
        await db.execute(
            select(VendorSubCategory).where(VendorSubCategory.vendor_id == vendor.id)
        )
    ).scalars().all()

    services = (
        await db.execute(
            select(VendorService).where(VendorService.vendor_id == vendor.id)
        )
    ).scalars().all()

    service_ids = [s.id for s in services]
    media_by_service: dict[int, list] = {}
    if service_ids:
        media_rows = (
            await db.execute(
                select(VendorServiceMedia).where(
                    VendorServiceMedia.vendor_service_id.in_(service_ids)
                )
            )
        ).scalars().all()
        for m in media_rows:
            media_by_service.setdefault(m.vendor_service_id, []).append(m)

    subcat_ids = {s.sub_category_id for s in services} | {r.sub_category_id for r in subcat_rows}
    main_cat_ids = {s.main_category_id for s in services} | {r.main_category_id for r in subcat_rows}

    subcat_map: dict[int, ServiceSubcategory] = {}
    if subcat_ids:
        subcat_map = {
            sc.id: sc
            for sc in (
                await db.execute(
                    select(ServiceSubcategory).where(ServiceSubcategory.id.in_(subcat_ids))
                )
            ).scalars().all()
        }

    main_cat_map: dict[int, ServiceCategory] = {}
    if main_cat_ids:
        main_cat_map = {
            mc.id: mc
            for mc in (
                await db.execute(
                    select(ServiceCategory).where(ServiceCategory.id.in_(main_cat_ids))
                )
            ).scalars().all()
        }

    catalog_service_ids = [s.service_id for s in services if s.service_id]
    catalog_service_map: dict[int, Service] = {}
    if catalog_service_ids:
        catalog_service_map = {
            cs.id: cs
            for cs in (
                await db.execute(
                    select(Service).where(Service.id.in_(catalog_service_ids))
                )
            ).scalars().all()
        }

    # Build subcategory keys from selections + services
    subcat_groups: dict[tuple[int, int], VendorCatalogSubCategoryGroup] = {}
    selected_subcat_keys = {
        (row.main_category_id, row.sub_category_id) for row in subcat_rows
    }

    for row in subcat_rows:
        key = (row.main_category_id, row.sub_category_id)
        sub = subcat_map.get(row.sub_category_id)
        subcat_groups.setdefault(
            key,
            VendorCatalogSubCategoryGroup(
                sub_category_id=row.sub_category_id,
                sub_category_name=sub.name if sub else "Unknown",
                main_category_id=row.main_category_id,
                services=[],
            ),
        )

    for svc in services:
        key = (svc.main_category_id, svc.sub_category_id)
        sub = subcat_map.get(svc.sub_category_id)
        if key not in subcat_groups:
            if not svc.is_active and key not in selected_subcat_keys:
                continue
            subcat_groups[key] = VendorCatalogSubCategoryGroup(
                sub_category_id=svc.sub_category_id,
                sub_category_name=sub.name if sub else "Unknown",
                main_category_id=svc.main_category_id,
                services=[],
            )

        cat_svc = catalog_service_map.get(svc.service_id) if svc.service_id else None
        media_items = [
            MediaItem(media_url=m.media_url, media_type=m.media_type)
            for m in media_by_service.get(svc.id, [])
        ]
        if not svc.is_active:
            continue

        subcat_groups[key].services.append(
            VendorCatalogServiceItem(
                id=svc.id,
                service_id=svc.service_id,
                title=svc.title or (cat_svc.name if cat_svc else "Service"),
                description=svc.description,
                price=float(svc.price) if svc.price else 0.0,
                discounted_price=float(svc.discounted_price) if svc.discounted_price else None,
                negotiable=bool(svc.negotiable),
                main_category_id=svc.main_category_id,
                sub_category_id=svc.sub_category_id,
                sub_category_name=subcat_groups[key].sub_category_name,
                is_active=True,
                image_url=cat_svc.image_url if cat_svc else None,
                media=media_items,
            )
        )

    subcat_groups = {
        key: group
        for key, group in subcat_groups.items()
        if group.services
    }

    main_groups: dict[int, VendorCatalogMainCategoryGroup] = {}
    for (main_id, _), sub_group in subcat_groups.items():
        main = main_cat_map.get(main_id)
        main_groups.setdefault(
            main_id,
            VendorCatalogMainCategoryGroup(
                main_category_id=main_id,
                main_category_name=main.name if main else "Category",
                icon_url=main.icon if main else None,
                sub_categories=[],
            ),
        )
        main_groups[main_id].sub_categories.append(sub_group)

    categories = sorted(main_groups.values(), key=lambda c: c.main_category_name)
    for cat in categories:
        cat.sub_categories.sort(key=lambda s: s.sub_category_name)

    total_services = len(services)
    total_active = sum(1 for s in services if s.is_active)

    return VendorCatalogResponse(
        categories=categories,
        total_services=total_services,
        total_active_services=total_active,
    )


@router.post("/me/categories")
async def add_vendor_categories(
    request: VendorCategoryAddRequest,
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db),
):
    """Add subcategory selections for a main category (idempotent)."""
    if not request.sub_category_ids:
        raise HTTPException(status_code=400, detail="Select at least one subcategory.")

    main_cat = (
        await db.execute(
            select(ServiceCategory).where(
                ServiceCategory.id == request.main_category_id,
                ServiceCategory.is_active == True,
            )
        )
    ).scalar_one_or_none()
    if not main_cat:
        raise HTTPException(status_code=404, detail="Main category not found.")

    valid_subcats = (
        await db.execute(
            select(ServiceSubcategory.id).where(
                ServiceSubcategory.main_category_id == request.main_category_id,
                ServiceSubcategory.id.in_(request.sub_category_ids),
                ServiceSubcategory.is_active == True,
            )
        )
    ).scalars().all()
    valid_ids = set(valid_subcats)
    if len(valid_ids) != len(set(request.sub_category_ids)):
        raise HTTPException(status_code=400, detail="Invalid subcategory selection.")

    existing = (
        await db.execute(
            select(VendorSubCategory.sub_category_id).where(
                VendorSubCategory.vendor_id == vendor.id,
                VendorSubCategory.main_category_id == request.main_category_id,
            )
        )
    ).scalars().all()
    existing_ids = set(existing)

    added = 0
    for sub_id in request.sub_category_ids:
        if sub_id in existing_ids:
            continue
        db.add(
            VendorSubCategory(
                vendor_id=vendor.id,
                main_category_id=request.main_category_id,
                sub_category_id=sub_id,
            )
        )
        added += 1

    await db.commit()
    return {"message": "Categories updated", "added": added}


@router.delete("/me/categories/sub-categories/{sub_category_id}")
async def remove_vendor_subcategory(
    sub_category_id: int,
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db),
):
    """Remove a subcategory selection and deactivate its services."""
    await db.execute(
        delete(VendorSubCategory).where(
            VendorSubCategory.vendor_id == vendor.id,
            VendorSubCategory.sub_category_id == sub_category_id,
        )
    )

    services = (
        await db.execute(
            select(VendorService).where(
                VendorService.vendor_id == vendor.id,
                VendorService.sub_category_id == sub_category_id,
            )
        )
    ).scalars().all()

    for svc in services:
        svc.is_active = False
        db.add(svc)

    await db.commit()
    return {
        "message": "Subcategory removed",
        "deactivated_services": len(services),
    }


@router.delete("/me/services/{vendor_service_id}")
async def delete_vendor_service(
    vendor_service_id: int,
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db),
):
    """Soft-delete a vendor service."""
    vendor_service = (
        await db.execute(
            select(VendorService).where(
                VendorService.id == vendor_service_id,
                VendorService.vendor_id == vendor.id,
            )
        )
    ).scalar_one_or_none()

    if not vendor_service:
        raise HTTPException(status_code=404, detail="Vendor service not found")

    vendor_service.is_active = False
    db.add(vendor_service)
    await db.commit()
    return {"message": "Service removed successfully"}


@router.post("/me/catalog/proceed")
async def proceed_catalog_to_payment(
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db),
):
    """Validate catalog before proceeding to subscription payment."""
    active_count = (
        await db.execute(
            select(VendorService.id).where(
                VendorService.vendor_id == vendor.id,
                VendorService.is_active == True,
            )
        )
    ).scalars().all()

    if not active_count:
        raise HTTPException(
            status_code=400,
            detail="Add at least one active service before proceeding to payment.",
        )

    return {
        "message": "Catalog ready for payment",
        "active_services": len(active_count),
        "proceed_to_payment": True,
    }


@router.post("/me/services/confirm-updates")
async def confirm_vendor_services_updates(
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    """
    Marks telecaller onboarded vendor's services as updated.
    """
    vendor.telecaller_services_updated = True
    db.add(vendor)
    await db.commit()
    return {"message": "Services updates confirmed successfully"}
