from typing import List, Optional
from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_db
from app.schemas.catalog import ServiceCategory, ServiceSubcategory, Package, VendorCategory, VendorServiceDetail, VendorBasicInfo, VendorServiceOffering, CategoryChildrenResponse, ServiceResponse
from sqlalchemy import select, text, func
from app.models.catalog import (
    ServiceCategory as CategoryModel, 
    ServiceSubcategory as SubcategoryModel, 
    Package as PackageModel,
    Service as ServiceModel
)
from sqlalchemy.orm import selectinload

router = APIRouter()

@router.get("/categories", response_model=List[ServiceCategory])
async def get_categories(
    db: AsyncSession = Depends(get_db),
    skip: int = 0,
    limit: int = 100
):
    """
    Get all top-level service categories (formerly known as Professions).
    """
    query = select(CategoryModel).options(selectinload(CategoryModel.subcategories)).where(CategoryModel.is_active == True).offset(skip).limit(limit)
    result = await db.execute(query)
    return result.scalars().all()


@router.get("/categories/by-pincode", response_model=List[VendorCategory])
async def get_categories_by_pincode(
    pincode: str = Query(..., description="Pincode to match"),
    search: Optional[str] = Query(None, description="Search query for category name"),
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    """
    Get main categories matched by pincode, with pagination and search.
    """
    from app.models.vendor import Vendor, VendorService

    query = (
        select(CategoryModel)
        .join(VendorService, VendorService.main_category_id == CategoryModel.id)
        .join(Vendor, Vendor.id == VendorService.vendor_id)
        .where(Vendor.pincode == pincode)
        .where(Vendor.status == "active")
        .where(VendorService.is_active == True)
        .where(CategoryModel.is_active == True)
    )

    if search:
        query = query.where(CategoryModel.name.ilike(f"%{search}%"))

    query = query.distinct().offset(skip).limit(limit)

    result = await db.execute(query)
    return result.scalars().all()

@router.get("/categories/{category_id}/children", response_model=CategoryChildrenResponse)
async def get_category_children(
    category_id: int,
    pincode: str = Query(..., description="Pincode to match"),
    search: Optional[str] = Query(None, description="Search query for name"),
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    """
    Get subcategories OR services for a given main category and pincode.
    """
    from app.models.vendor import Vendor, VendorService

    # Check if the category has any subcategories globally
    subcat_count_query = select(func.count(SubcategoryModel.id)).where(SubcategoryModel.main_category_id == category_id)
    result = await db.execute(subcat_count_query)
    has_subcategories = result.scalar() > 0

    if has_subcategories:
        query = (
            select(SubcategoryModel)
            .join(VendorService, VendorService.sub_category_id == SubcategoryModel.id)
            .join(Vendor, Vendor.id == VendorService.vendor_id)
            .where(SubcategoryModel.main_category_id == category_id)
            .where(Vendor.pincode == pincode)
            .where(SubcategoryModel.is_active == True)
        )
        if search:
            query = query.where(SubcategoryModel.name.ilike(f"%{search}%"))
    else:
        query = (
            select(ServiceModel)
            .join(VendorService, VendorService.service_id == ServiceModel.id)
            .join(Vendor, Vendor.id == VendorService.vendor_id)
            .where(ServiceModel.main_category_id == category_id)
            .where(Vendor.pincode == pincode)
            .where(ServiceModel.is_active == True)
        )
        if search:
            query = query.where(ServiceModel.name.ilike(f"%{search}%"))

    query = query.distinct().offset(skip).limit(limit)
    result = await db.execute(query)
    data = result.scalars().all()

    return {
        "is_subcategory": has_subcategories,
        "data": data
    }


@router.get("/vendors", response_model=List[VendorBasicInfo])
async def get_vendors(
    category_id: Optional[int] = Query(None, description="Filter by main category ID"),
    subcategory_id: Optional[int] = Query(None, description="Filter by subcategory ID"),
    service_id: Optional[int] = Query(None, description="Filter by service ID"),
    pincode: Optional[str] = Query(None, description="Customer pincode for location fallback"),
    latitude: Optional[float] = Query(None, description="Customer latitude"),
    longitude: Optional[float] = Query(None, description="Customer longitude"),
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    """
    Get vendors for a service area using subscription eligibility, lead fairness,
    plan visibility, and radius expansion up to 70 km.
    """
    from app.models.vendor import Vendor, VendorService
    from app.models.subscriptions import VendorSubscription, SubscriptionPlan
    from app.models.orders import Order
    from app.core.geo import (
        SEARCH_RADII_KM,
        haversine_km,
        resolve_customer_coordinates,
    )
    from datetime import datetime
    from sqlalchemy import func, or_

    if not category_id and not subcategory_id and not service_id:
        raise HTTPException(
            status_code=400,
            detail="Must provide at least one of category_id, subcategory_id, or service_id",
        )

    subcat_query = select(VendorService.vendor_id).where(VendorService.is_active == True)
    if category_id:
        subcat_query = subcat_query.where(VendorService.main_category_id == category_id)
    if subcategory_id:
        subcat_query = subcat_query.where(VendorService.sub_category_id == subcategory_id)
    if service_id:
        subcat_query = subcat_query.where(VendorService.service_id == service_id)

    matching_vendor_ids = subcat_query.scalar_subquery()

    bookings_count_sub = (
        select(func.count(Order.id))
        .where(Order.vendor_id == Vendor.id)
        .where(Order.created_at >= VendorSubscription.start_date)
        .where(Order.created_at <= VendorSubscription.end_date)
        .where(Order.status != "CANCELLED")
        .correlate(Vendor)
        .correlate(VendorSubscription)
        .scalar_subquery()
    )

    query = (
        select(Vendor, SubscriptionPlan, bookings_count_sub.label("bookings_count"))
        .join(VendorSubscription, VendorSubscription.vendor_id == Vendor.id)
        .join(SubscriptionPlan, VendorSubscription.subscription_plan_id == SubscriptionPlan.id)
        .where(Vendor.id.in_(matching_vendor_ids))
        .where(Vendor.status == "active")
        .where(VendorSubscription.status == "active")
        .where(VendorSubscription.end_date >= datetime.utcnow())
        .where(
            or_(
                SubscriptionPlan.free_leads <= 0,
                SubscriptionPlan.free_leads == -1,
                bookings_count_sub < SubscriptionPlan.free_leads,
            )
        )
    )

    result = await db.execute(query)
    rows = result.all()

    customer_lat, customer_lon = await resolve_customer_coordinates(
        db, latitude, longitude, pincode
    )

    candidates = []
    for vendor, plan, bookings_count in rows:
        bookings_count = int(bookings_count or 0)
        distance_km = None

        if customer_lat is not None and customer_lon is not None:
            if vendor.latitude is not None and vendor.longitude is not None:
                distance_km = haversine_km(
                    customer_lat,
                    customer_lon,
                    float(vendor.latitude),
                    float(vendor.longitude),
                )
            elif pincode and vendor.pincode and vendor.pincode.strip() == pincode.strip():
                distance_km = 0.0

        candidates.append(
            {
                "vendor": vendor,
                "plan": plan,
                "bookings_count": bookings_count,
                "distance_km": distance_km,
            }
        )

    matched = candidates
    if customer_lat is not None and customer_lon is not None:
        located = [c for c in candidates if c["distance_km"] is not None]
        matched = []

        for radius in SEARCH_RADII_KM:
            in_radius = []
            for item in located:
                vendor_radius = item["vendor"].service_radius_km or 10
                if item["distance_km"] <= radius and item["distance_km"] <= vendor_radius:
                    in_radius.append(item)
            if in_radius:
                matched = in_radius
                break

        if not matched and pincode:
            matched = [
                c
                for c in candidates
                if c["distance_km"] is None
                and c["vendor"].pincode
                and c["vendor"].pincode.strip() == pincode.strip()
            ]

        if not matched:
            matched = located or candidates

    matched.sort(
        key=lambda item: (
            item["bookings_count"],
            -(item["plan"].visibility_boost or 0),
            item["distance_km"] if item["distance_km"] is not None else 9999.0,
            -(float(item["vendor"].avg_rating or 0)),
        )
    )

    paginated = matched[skip : skip + limit]

    service_price_map: dict[int, tuple[float, bool]] = {}
    if service_id and paginated:
        vendor_ids = [item["vendor"].id for item in paginated]
        price_res = await db.execute(
            select(
                VendorService.vendor_id,
                VendorService.price,
                VendorService.discounted_price,
                VendorService.negotiable,
            ).where(
                VendorService.vendor_id.in_(vendor_ids),
                VendorService.service_id == service_id,
                VendorService.is_active == True,
            )
        )
        for row in price_res.fetchall():
            effective = float(row.discounted_price or row.price or 0)
            service_price_map[row.vendor_id] = (effective, bool(row.negotiable))

    response_items = []
    for item in paginated:
        vendor = item["vendor"]
        price_info = service_price_map.get(vendor.id)
        response_items.append(
            VendorBasicInfo(
                id=vendor.id,
                business_name=vendor.business_name,
                business_description=vendor.business_description,
                years_of_experience=0,
                avg_rating=float(vendor.avg_rating or 0),
                total_reviews=int(vendor.total_reviews or 0),
                is_verified=False,
                photo_url=vendor.photo_url,
                banner_url=vendor.background_banner,
                approx_visit_charge=None,
                discount=0,
                operating_city=vendor.operating_city,
                distance_km=round(item["distance_km"], 1)
                if item["distance_km"] is not None
                else None,
                leads_consumed=item["bookings_count"],
                service_price=price_info[0] if price_info else None,
                service_negotiable=price_info[1] if price_info else False,
            )
        )

    return response_items



@router.get("/subcategories", response_model=List[ServiceSubcategory])
async def get_subcategories(
    db: AsyncSession = Depends(get_db),
    category_id: Optional[int] = None,
    skip: int = 0,
    limit: int = 100
):
    """
    Get service subcategories, optionally filtered by category.
    """
    query = select(SubcategoryModel).where(SubcategoryModel.is_active == True)
    if category_id:
        query = query.where(SubcategoryModel.main_category_id == category_id)
    
    query = query.offset(skip).limit(limit)
    result = await db.execute(query)
    return result.scalars().all()


@router.get("/packages", response_model=List[Package])
async def get_packages(
    db: AsyncSession = Depends(get_db),
    subcategory_id: Optional[int] = None,
    category_id: Optional[int] = None,
):
    """
    Get service packages.
    """
    query = select(PackageModel).options(
        selectinload(PackageModel.sub_packages),
        selectinload(PackageModel.benefits),
        selectinload(PackageModel.inclusion_steps),
        selectinload(PackageModel.inclusion_bullets),
        selectinload(PackageModel.exclusion_steps),
        selectinload(PackageModel.exclusion_bullets),
        selectinload(PackageModel.precautions),
        selectinload(PackageModel.brands),
        selectinload(PackageModel.safety),
        selectinload(PackageModel.sections),
        selectinload(PackageModel.faqs)
    ).where(PackageModel.is_active == True)

    if subcategory_id:
        query = query.where(PackageModel.subcategory_id == subcategory_id)

    result = await db.execute(query)
    return result.scalars().all()



@router.get("/services")
async def get_services(
    db: AsyncSession = Depends(get_db),
    main_category_id: Optional[int] = None,
    subcategory_id: Optional[int] = None,
    skip: int = 0,
    limit: int = 100
):
    """
    Get services filtered by main_category_id and/or subcategory_id.
    """
    # Import locally to avoid cyclic dependency or missing import errors for now
    from app.models.catalog import Service
    query = select(Service).where(Service.is_active == True)
    
    if main_category_id:
        query = query.where(Service.main_category_id == main_category_id)
    if subcategory_id:
        query = query.where(Service.sub_category_id == subcategory_id)
        
    query = query.offset(skip).limit(limit)
    result = await db.execute(query)
    
    return result.scalars().all()


@router.get("/vendors/{vendor_id}/categories", response_model=List[VendorCategory])
async def get_vendor_categories(
    vendor_id: int,
    db: AsyncSession = Depends(get_db)
):
    """
    Get all categories that a specific vendor provides services for.
    """
    # 1. Check if vendor profile exists
    vendor_exists = await db.execute(
        text("SELECT id FROM vendor_profiles WHERE id = :vendor_id"),
        {"vendor_id": vendor_id}
    )
    if not vendor_exists.fetchone():
        raise HTTPException(status_code=404, detail="Vendor profile not found")

    # 2. Get all active subcategory IDs for the vendor
    subquery_res = await db.execute(
        text("SELECT subcategory_id FROM vendor_services WHERE vendor_profile_id = :vendor_id AND is_active = true"),
        {"vendor_id": vendor_id}
    )
    subcat_ids = [row[0] for row in subquery_res.fetchall()]

    if not subcat_ids:
        return []

    # 3. Get distinct categories containing these subcategories
    query = (
        select(CategoryModel)
        .join(SubcategoryModel, SubcategoryModel.category_id == CategoryModel.id)
        .where(SubcategoryModel.id.in_(subcat_ids))
        .where(CategoryModel.is_active == True)
        .where(SubcategoryModel.is_active == True)
        .distinct()
    )
    result = await db.execute(query)
    return result.scalars().all()

@router.get("/vendors/{vendor_id}/categories/{category_id}/services", response_model=List[VendorServiceDetail])
async def get_vendor_category_services(
    vendor_id: int,
    category_id: int,
    db: AsyncSession = Depends(get_db)
):
    """
    Get all services (subcategories and their packages) of a specific category provided by a vendor.
    """
    # 1. Check if vendor profile exists
    vendor_exists = await db.execute(
        text("SELECT id FROM vendor_profiles WHERE id = :vendor_id"),
        {"vendor_id": vendor_id}
    )
    if not vendor_exists.fetchone():
        raise HTTPException(status_code=404, detail="Vendor profile not found")

    # 2. Check if category exists
    cat_exists = await db.execute(
        select(CategoryModel).where(CategoryModel.id == category_id, CategoryModel.is_active == True)
    )
    if not cat_exists.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Category not found")

    # 3. Query active subcategories under this category
    query = (
        select(SubcategoryModel)
        .where(SubcategoryModel.category_id == category_id)
        .where(SubcategoryModel.is_active == True)
    )
    subcat_res = await db.execute(query)
    subcategories = subcat_res.scalars().all()

    if not subcategories:
        return []

    # 4. Fetch the vendor's mapping (pricing, etc.) for subcategories
    mapping_res = await db.execute(
        text("SELECT subcategory_id, price_range_min, price_range_max, pricing_type FROM vendor_services WHERE vendor_profile_id = :vendor_id AND is_active = true"),
        {"vendor_id": vendor_id}
    )
    mappings = {row[0]: row for row in mapping_res.fetchall()}

    # Filter subcategories to only those mapped and active for this vendor
    filtered_subcategories = [sc for sc in subcategories if sc.id in mappings]

    if not filtered_subcategories:
        return []

    # 5. Fetch all active packages for these subcategories
    pkg_query = select(PackageModel).options(
        selectinload(PackageModel.sub_packages),
        selectinload(PackageModel.benefits),
        selectinload(PackageModel.inclusion_steps),
        selectinload(PackageModel.inclusion_bullets),
        selectinload(PackageModel.exclusion_steps),
        selectinload(PackageModel.exclusion_bullets),
        selectinload(PackageModel.precautions),
        selectinload(PackageModel.brands),
        selectinload(PackageModel.safety),
        selectinload(PackageModel.sections),
        selectinload(PackageModel.faqs)
    ).where(
        PackageModel.subcategory_id.in_([sc.id for sc in filtered_subcategories]),
        PackageModel.is_active == True
    )
    pkg_res = await db.execute(pkg_query)
    packages = pkg_res.scalars().all()

    # Group packages by subcategory_id
    pkgs_by_subcat = {}
    for pkg in packages:
        pkgs_by_subcat.setdefault(pkg.subcategory_id, []).append(pkg)

    # 6. Construct response items
    response_items = []
    for sc in filtered_subcategories:
        map_row = mappings[sc.id]
        response_items.append(
            VendorServiceDetail(
                id=sc.id,
                name=sc.name,
                description=sc.description,
                icon_url=sc.icon_url,
                category_id=sc.category_id,
                price_range_min=map_row[1],
                price_range_max=map_row[2],
                pricing_type=map_row[3],
                packages=pkgs_by_subcat.get(sc.id, [])
            )
        )

    return response_items

@router.get("/categories/{category_id}/vendors", response_model=List[VendorBasicInfo])
async def get_category_vendors(
    category_id: int,
    db: AsyncSession = Depends(get_db)
):
    """
    Get all vendors who provide services under a specific category.
    """
    # 1. Check if category exists and is active
    cat_exists = await db.execute(
        select(CategoryModel).where(CategoryModel.id == category_id, CategoryModel.is_active == True)
    )
    if not cat_exists.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Category not found")

    # 2. Get all subcategory IDs under this category
    subcat_res = await db.execute(
        select(SubcategoryModel.id).where(SubcategoryModel.category_id == category_id, SubcategoryModel.is_active == True)
    )
    subcat_ids = [row[0] for row in subcat_res.fetchall()]

    if not subcat_ids:
        return []

    # 3. Query all active vendors who have mapped active services for these subcategories
    subcat_ids_str = ",".join(str(i) for i in subcat_ids)
    query = f"""
    SELECT DISTINCT vp.id, vp.business_name, vp.business_description, vp.years_of_experience, 
                    vp.avg_rating, vp.total_reviews, vp.is_verified, vp.photo_url, vp.banner_url, 
                    vp.approx_visit_charge, vp.discount, vp.operating_city
    FROM vendor_profiles vp
    JOIN vendor_services vs ON vs.vendor_profile_id = vp.id
    WHERE vs.subcategory_id IN ({subcat_ids_str}) 
      AND vs.is_active = true 
      AND vp.approval_status = 'APPROVED'
    """
    vendors_res = await db.execute(text(query))

    response_items = []
    for row in vendors_res.fetchall():
        response_items.append(
            VendorBasicInfo(
                id=row[0],
                business_name=row[1],
                business_description=row[2],
                years_of_experience=row[3] or 0,
                avg_rating=row[4] or 0.0,
                total_reviews=row[5] or 0,
                is_verified=row[6] or False,
                photo_url=row[7],
                banner_url=row[8],
                approx_visit_charge=row[9],
                discount=row[10] or 0,
                operating_city=row[11]
            )
        )
    return response_items

@router.get("/vendors/{vendor_id}/profile-id")
async def get_vendor_profile_id(
    vendor_id: int,
    db: AsyncSession = Depends(get_db),
):
    """
    Resolve booking vendor ID from vendors.id.
    """
    from app.models.vendor import Vendor

    result = await db.execute(select(Vendor).where(Vendor.id == vendor_id))
    vendor = result.scalar_one_or_none()
    if not vendor:
        raise HTTPException(status_code=404, detail="Vendor not found")

    return {"vendor_profile_id": vendor.id}


@router.get("/vendors/{vendor_id}/services", response_model=List[VendorServiceOffering])
async def get_vendor_services(
    vendor_id: int,
    category_id: Optional[int] = Query(None, description="Filter by main category ID"),
    subcategory_id: Optional[int] = Query(None, description="Filter by subcategory ID"),
    db: AsyncSession = Depends(get_db),
):
    """
    Get active services offered by a vendor (price + fixed/negotiable from registration).
    """
    from app.models.vendor import Vendor, VendorService, VendorServiceMedia
    from app.models.catalog import Service as CatalogService

    vendor_res = await db.execute(
        select(Vendor).where(Vendor.id == vendor_id, Vendor.status == "active")
    )
    vendor = vendor_res.scalar_one_or_none()
    if not vendor:
        raise HTTPException(status_code=404, detail="Vendor not found")

    query = select(VendorService).where(
        VendorService.vendor_id == vendor_id,
        VendorService.is_active == True,
    )
    if category_id:
        query = query.where(VendorService.main_category_id == category_id)
    if subcategory_id:
        query = query.where(VendorService.sub_category_id == subcategory_id)

    services_res = await db.execute(query.order_by(VendorService.id))
    services = services_res.scalars().all()
    if not services:
        return []

    subcat_ids = {s.sub_category_id for s in services if s.sub_category_id}
    subcat_map = {}
    if subcat_ids:
        subcat_rows = await db.execute(
            select(SubcategoryModel).where(SubcategoryModel.id.in_(subcat_ids))
        )
        subcat_map = {sc.id: sc for sc in subcat_rows.scalars().all()}

    catalog_service_ids = {s.service_id for s in services if s.service_id}
    catalog_service_map = {}
    if catalog_service_ids:
        catalog_rows = await db.execute(
            select(CatalogService).where(CatalogService.id.in_(catalog_service_ids))
        )
        catalog_service_map = {cs.id: cs for cs in catalog_rows.scalars().all()}

    service_ids = [s.id for s in services]
    media_map: dict[int, str] = {}
    if service_ids:
        media_rows = await db.execute(
            select(VendorServiceMedia).where(
                VendorServiceMedia.vendor_service_id.in_(service_ids),
                VendorServiceMedia.media_type == "image",
            )
        )
        for media in media_rows.scalars().all():
            media_map.setdefault(media.vendor_service_id, media.media_url)

    response_items = []
    for service in services:
        subcat = subcat_map.get(service.sub_category_id)
        catalog_service = catalog_service_map.get(service.service_id)
        image_url = media_map.get(service.id) or (
            catalog_service.image_url if catalog_service else None
        )
        response_items.append(
            VendorServiceOffering(
                id=service.id,
                service_id=service.service_id,
                title=service.title or (catalog_service.name if catalog_service else "Service"),
                description=service.description,
                price=float(service.price or 0),
                discounted_price=float(service.discounted_price)
                if service.discounted_price
                else None,
                negotiable=bool(service.negotiable),
                main_category_id=service.main_category_id,
                sub_category_id=service.sub_category_id,
                sub_category_name=subcat.name if subcat else None,
                image_url=image_url,
            )
        )

    return response_items
