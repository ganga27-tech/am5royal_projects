from typing import List
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.db.session import get_db
from app.models.catalog import ServiceCategory, ServiceSubcategory, Package, Service
from app.models.vendor import Vendor, VendorSubCategory, VendorService, VendorServiceMedia
from app.models.user_location import User
from app.dependencies.auth import get_current_vendor, get_current_token_payload
from app.schemas.vendor_catalog import (
    VendorMainCategoryResponse,
    VendorSubCategoryResponse,
    VendorServiceResponse,
    BatchServicesRequest,
    VendorServiceAddRequest
)

router = APIRouter()

@router.get("/main-categories", response_model=List[VendorMainCategoryResponse])
async def get_main_categories(
    db: AsyncSession = Depends(get_db),
    token_payload: dict = Depends(get_current_token_payload)
):
    """
    Fetches all Main Categories.
    Dynamically determines `has_subcategories` based on whether there are more than 0 active subcategories.
    """
    query = select(ServiceCategory).options(selectinload(ServiceCategory.subcategories)).where(ServiceCategory.is_active == True)
    result = await db.execute(query)
    categories = result.scalars().all()
    
    response = []
    for cat in categories:
        active_subcats = [sub for sub in cat.subcategories if sub.is_active]
        response.append(
            VendorMainCategoryResponse(
                id=cat.id,
                name=cat.name,
                icon_url=cat.icon,
                has_subcategories=len(active_subcats) > 0
            )
        )
    return response

@router.get("/main-categories/{category_id}/sub-categories", response_model=List[VendorSubCategoryResponse])
async def get_subcategories(
    category_id: int, 
    db: AsyncSession = Depends(get_db),
    token_payload: dict = Depends(get_current_token_payload)
):
    """
    Returns active sub-categories for a specific main category along with vendor selection state.
    """
    vendor_id = token_payload.get("vendor_id")
    token_sub = str(token_payload.get("sub", ""))
    selected_subcat_ids = set()

    if not vendor_id and token_sub.isdigit():
        v_user_res = await db.execute(
            select(Vendor.id).where(Vendor.user_id == int(token_sub))
        )
        v_row = v_user_res.scalar_one_or_none()
        if v_row:
            vendor_id = v_row

    if vendor_id:
        v_res = await db.execute(
            select(VendorSubCategory.sub_category_id).where(VendorSubCategory.vendor_id == vendor_id)
        )
        selected_subcat_ids = {row[0] for row in v_res.fetchall()}

    query = select(ServiceSubcategory).where(
        ServiceSubcategory.main_category_id == category_id,
        ServiceSubcategory.is_active == True
    )
    result = await db.execute(query)
    subcats = result.scalars().all()

    response = []
    for sc in subcats:
        response.append(
            VendorSubCategoryResponse(
                id=sc.id,
                name=sc.name,
                icon_url=sc.icon_url,
                is_selected=sc.id in selected_subcat_ids
            )
        )
    return response

@router.get("/main-categories/{category_id}/services", response_model=List[VendorServiceResponse])
async def get_services_for_category(
    category_id: int, 
    db: AsyncSession = Depends(get_db),
    token_payload: dict = Depends(get_current_token_payload)
):
    """
    Returns services for a main category directly.
    Finds all subcategories under the category and returns all their services.
    """
    # Find all subcategory ids for this category
    subcat_query = select(ServiceSubcategory.id).where(
        ServiceSubcategory.main_category_id == category_id,
        ServiceSubcategory.is_active == True
    )
    subcat_res = await db.execute(subcat_query)
    subcat_ids = [row[0] for row in subcat_res.fetchall()]
    
    if subcat_ids:
        svc_query = select(Service).where(
            (Service.sub_category_id.in_(subcat_ids)) | (Service.main_category_id == category_id),
            Service.is_active == True
        )
    else:
        svc_query = select(Service).where(
            Service.main_category_id == category_id,
            Service.is_active == True
        )
    svc_res = await db.execute(svc_query)
    services = svc_res.scalars().all()
    if services:
        return services

    # Fallback to packages table if no services in services table
    if subcat_ids:
        pkg_query = select(Package).where(
            Package.subcategory_id.in_(subcat_ids),
            Package.is_active == True
        )
        pkg_res = await db.execute(pkg_query)
        return pkg_res.scalars().all()
    
    return []

@router.post("/sub-categories/services-batch", response_model=List[VendorServiceResponse])
async def get_services_batch(
    request: BatchServicesRequest, 
    db: AsyncSession = Depends(get_db),
    token_payload: dict = Depends(get_current_token_payload)
):
    """
    Returns all services for multiple subcategories at once.
    """
    if not request.sub_category_ids:
        return []
        
    svc_query = select(Service).where(
        Service.sub_category_id.in_(request.sub_category_ids),
        Service.is_active == True
    )
    svc_res = await db.execute(svc_query)
    services = svc_res.scalars().all()
    
    if services:
        return services

    # Fallback to packages table if no services found in services table
    pkg_query = select(Package).where(
        Package.subcategory_id.in_(request.sub_category_ids),
        Package.is_active == True
    )
    pkg_res = await db.execute(pkg_query)
    return pkg_res.scalars().all()

@router.post("/add-service")
async def add_vendor_service(
    request: VendorServiceAddRequest,
    background_tasks: BackgroundTasks,
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    """
    Adds a service to the vendor's profile in vendor_services.
    """
    # 1. Check if service exists
    service_query = select(Service).where(Service.id == request.service_id)
    service_res = await db.execute(service_query)
    service = service_res.scalar_one_or_none()
    
    if not service:
        raise HTTPException(status_code=404, detail="Service not found")
        
    # Check if vendor already has this service
    existing_query = select(VendorService).where(
        VendorService.vendor_id == vendor.id,
        VendorService.service_id == request.service_id
    )
    existing_res = await db.execute(existing_query)
    existing_service = existing_res.scalar_one_or_none()
    if existing_service:
        existing_service.price = request.amount
        existing_service.negotiable = request.is_negotiable
        db.add(existing_service)
        
        # Handle media updates (clear existing and add new)
        from sqlalchemy import delete
        await db.execute(delete(VendorServiceMedia).where(VendorServiceMedia.vendor_service_id == existing_service.id))
        
        if request.media:
            for m in request.media:
                new_media = VendorServiceMedia(
                    vendor_service_id=existing_service.id,
                    media_type=m.media_type,
                    media_url=m.media_url
                )
                db.add(new_media)
                
        await db.commit()
        return {"message": "Service updated successfully", "id": existing_service.id}
        
    # Create new vendor service
    vendor_service = VendorService(
        vendor_id=vendor.id,
        main_category_id=service.main_category_id,
        sub_category_id=service.sub_category_id,
        service_id=service.id,
        title=service.name,
        price=request.amount,
        negotiable=request.is_negotiable,
        is_active=True
    )
    
    db.add(vendor_service)
    await db.commit()
    await db.refresh(vendor_service)

    # Auto-upsert into vendor_sub_categories so subcategory shows as selected
    existing_subcat = await db.execute(
        select(VendorSubCategory).where(
            VendorSubCategory.vendor_id == vendor.id,
            VendorSubCategory.sub_category_id == service.sub_category_id,
        )
    )
    if not existing_subcat.scalar_one_or_none():
        db.add(VendorSubCategory(
            vendor_id=vendor.id,
            main_category_id=service.main_category_id,
            sub_category_id=service.sub_category_id,
        ))
        await db.commit()
    
    # Handle media
    if request.media:
        for m in request.media:
            new_media = VendorServiceMedia(
                vendor_service_id=vendor_service.id,
                media_type=m.media_type,
                media_url=m.media_url
            )
            db.add(new_media)
            
        await db.commit()
    
    return {"message": "Service added successfully", "id": vendor_service.id}


@router.delete("/remove-service/{service_id}")
async def remove_vendor_service(
    service_id: int,
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    """
    Removes a service from the vendor's profile in vendor_services.
    Also deletes any associated media.
    """
    from sqlalchemy import delete

    # Find the vendor service entry
    query = select(VendorService).where(
        VendorService.vendor_id == vendor.id,
        VendorService.service_id == service_id
    )
    res = await db.execute(query)
    vendor_service = res.scalar_one_or_none()

    if not vendor_service:
        # Also check if passed ID is the vendor_services record primary key
        query_by_id = select(VendorService).where(
            VendorService.vendor_id == vendor.id,
            VendorService.id == service_id
        )
        res_by_id = await db.execute(query_by_id)
        vendor_service = res_by_id.scalar_one_or_none()

    if not vendor_service:
        raise HTTPException(status_code=404, detail="Service not found for this vendor")

    # Delete media associated with vendor service
    await db.execute(delete(VendorServiceMedia).where(VendorServiceMedia.vendor_service_id == vendor_service.id))

    # Delete vendor service entry
    await db.delete(vendor_service)
    await db.commit()

    return {"message": "Service removed successfully", "service_id": service_id}


@router.delete("/remove-subcategory/{sub_category_id}")
async def remove_vendor_subcategory_catalog(
    sub_category_id: int,
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db)
):
    """
    Removes a subcategory from vendor profile and completely deletes all associated services and media.
    """
    from sqlalchemy import delete

    # Find all services under this subcategory for this vendor
    services = (
        await db.execute(
            select(VendorService).where(
                VendorService.vendor_id == vendor.id,
                VendorService.sub_category_id == sub_category_id,
            )
        )
    ).scalars().all()

    service_ids = [svc.id for svc in services]

    if service_ids:
        # Delete associated media
        await db.execute(
            delete(VendorServiceMedia).where(
                VendorServiceMedia.vendor_service_id.in_(service_ids)
            )
        )
        # Delete the vendor services completely from DB
        await db.execute(
            delete(VendorService).where(
                VendorService.id.in_(service_ids)
            )
        )

    # Delete the vendor subcategory entry completely from DB
    await db.execute(
        delete(VendorSubCategory).where(
            VendorSubCategory.vendor_id == vendor.id,
            VendorSubCategory.sub_category_id == sub_category_id,
        )
    )

    await db.commit()
    return {
        "message": "Subcategory services removed successfully",
        "sub_category_id": sub_category_id,
        "deleted_services_count": len(services),
    }




@router.post("/complete-service-selection")
async def complete_service_selection(
    background_tasks: BackgroundTasks,
    vendor: Vendor = Depends(get_current_vendor),
    db: AsyncSession = Depends(get_db),
):
    """
    Called when vendor finishes adding services and taps PROCEED.
    Sends KYC reminder push/SMS once (until documents are uploaded).
    """
    from sqlalchemy import text

    flags = (
        await db.execute(
            text("""
                SELECT
                    EXISTS(
                        SELECT 1 FROM vendor_services WHERE vendor_id = :vendor_id
                    ) AS has_services,
                    EXISTS(
                        SELECT 1 FROM vendor_documents WHERE vendor_id = :vendor_id
                    ) AS has_documents
            """),
            {"vendor_id": vendor.id},
        )
    ).one()

    if not flags.has_services:
        raise HTTPException(
            status_code=400,
            detail="Add at least one service before proceeding.",
        )

    if flags.has_documents:
        return {
            "message": "Service selection completed",
            "notification_sent": False,
        }

    user = (
        await db.execute(select(User).where(User.id == vendor.user_id))
    ).scalar_one_or_none()

    if user:
        from app.services.notification_service import send_user_push_notification

        background_tasks.add_task(
            send_user_push_notification,
            user_id=user.id,
            title="Complete Your KYC Verification",
            body="Dear Vendor, complete your KYC by uploading the required documents to activate your account.",
        )

    return {
        "message": "Service selection completed successfully",
        "notification_sent": bool(user),
    }


