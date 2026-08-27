from datetime import date, datetime, timedelta
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List

from app.db.session import get_db
from app.models.employee import Employee, WithdrawalRequest
from app.schemas.employee import EmployeeCreate, EmployeeResponse, EmployeeLogin, Token, EmployeeUpdateRequest, WhatsAppInviteRequest
from app.schemas.withdrawal import WithdrawalRequestCreate, WithdrawalRequestResponse
from app.core.security import get_password_hash, verify_password, create_access_token
from app.dependencies.auth import get_current_employee, get_current_admin

router = APIRouter()

@router.post("/", response_model=EmployeeResponse, status_code=status.HTTP_201_CREATED)
async def create_employee(
    employee_in: EmployeeCreate,
    db: AsyncSession = Depends(get_db),
    current_admin = Depends(get_current_admin)
):
    # Check if employee with same email or phone exists
    query = select(Employee).where(
        (Employee.email == employee_in.email) | 
        (Employee.phone_number == employee_in.phone_number)
    )
    result = await db.execute(query)
    if result.scalars().first():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Employee with this email or phone number already exists"
        )
        
    new_employee = Employee(
        first_name=employee_in.first_name,
        last_name=employee_in.last_name,
        email=employee_in.email,
        phone_number=employee_in.phone_number,
        hashed_password=get_password_hash(employee_in.password),
        role=employee_in.role
    )
    db.add(new_employee)
    await db.commit()
    await db.refresh(new_employee)
    return new_employee

@router.post("/login", response_model=Token)
async def login_employee(
    login_data: EmployeeLogin,
    db: AsyncSession = Depends(get_db)
):
    # Authenticate employee by email or phone_number
    query = select(Employee).where(
        (Employee.email == login_data.identifier) |
        (Employee.phone_number == login_data.identifier)
    )
    result = await db.execute(query)
    employee = result.scalar_one_or_none()
    
    if not employee or not verify_password(login_data.password, employee.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect identifier or password",
        )
        
    if employee.status != "active":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Employee account is not active",
        )
        
    # Generate token
    access_token = create_access_token(subject=str(employee.id))
    return {
        "access_token": access_token, 
        "token_type": "bearer",
        "role": employee.role
    }

@router.get("/me", response_model=EmployeeResponse)
async def read_employee_me(
    current_employee: Employee = Depends(get_current_employee),
    db: AsyncSession = Depends(get_db)
):
    from sqlalchemy import text
    from datetime import date
    
    res = await db.execute(text("SELECT points FROM employee_daily_points WHERE employee_id = :emp_id AND date = :today"), {"emp_id": current_employee.id, "today": date.today()})
    today_points = res.scalar_one_or_none() or 0
    
    return {
        "id": current_employee.id,
        "first_name": current_employee.first_name,
        "last_name": current_employee.last_name,
        "email": current_employee.email,
        "phone_number": current_employee.phone_number,
        "role": current_employee.role,
        "status": current_employee.status,
        "referral_points": current_employee.referral_points,
        "bank_name": current_employee.bank_name,
        "bank_account_number": current_employee.bank_account_number,
        "bank_account_name": current_employee.bank_account_name,
        "bank_ifsc_code": current_employee.bank_ifsc_code
    }

@router.put("/me", response_model=EmployeeResponse)
async def update_employee_me(
    employee_in: EmployeeUpdateRequest,
    current_employee: Employee = Depends(get_current_employee),
    db: AsyncSession = Depends(get_db)
):
    update_data = employee_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(current_employee, field, value)
        
    await db.commit()
    await db.refresh(current_employee)
    
    from sqlalchemy import text
    from datetime import date
    res = await db.execute(text("SELECT points FROM employee_daily_points WHERE employee_id = :emp_id AND date = :today"), {"emp_id": current_employee.id, "today": date.today()})
    today_points = res.scalar_one_or_none() or 0

    return {
        "id": current_employee.id,
        "first_name": current_employee.first_name,
        "last_name": current_employee.last_name,
        "email": current_employee.email,
        "phone_number": current_employee.phone_number,
        "role": current_employee.role,
        "status": current_employee.status,
        "referral_points": current_employee.referral_points,
        "bank_name": current_employee.bank_name,
        "bank_account_number": current_employee.bank_account_number,
        "bank_account_name": current_employee.bank_account_name,
        "bank_ifsc_code": current_employee.bank_ifsc_code
    }
@router.get("/", response_model=List[EmployeeResponse])
async def list_employees(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_admin = Depends(get_current_admin)
):
    query = select(Employee).offset(skip).limit(limit)
    result = await db.execute(query)
    employees = result.scalars().all()
    return employees

from app.schemas.vendor_registration import VendorRegistrationRequest
from app.models.user_location import User
from app.models.vendor import Vendor, VendorSubCategory
from sqlalchemy import delete

@router.post("/vendors/onboard", response_model=dict)
async def onboard_vendor(
    mobile: str,
    request: VendorRegistrationRequest,
    current_employee: Employee = Depends(get_current_employee),
    db: AsyncSession = Depends(get_db)
):
    # Check if user exists
    user_query = await db.execute(select(User).where(User.mobile == mobile))
    user = user_query.scalar_one_or_none()
    
    if not user:
        user = User(
            mobile=mobile,
            email=None,
            role="VENDOR",
            is_active=True,
            otp_verified=True
        )
        db.add(user)
        await db.flush()
    else:
        if not user.role:
            user.role = "VENDOR"
        elif "VENDOR" not in str(user.role):
            user.role = str(user.role) + ",VENDOR"
        db.add(user)
        await db.flush()

    # Check if vendor already exists
    vendor_query = await db.execute(select(Vendor).where(Vendor.user_id == user.id))
    vendor = vendor_query.scalar_one_or_none()
    
    if vendor and vendor.status == "active":
        raise HTTPException(status_code=400, detail="Vendor is already fully registered")
        
    if not vendor:
        vendor = Vendor(
            user_id=user.id,
            status="onboarding"
        )
        db.add(vendor)
        await db.flush()
        
    # Update Vendor Profile
    vendor.first_name = request.first_name
    vendor.last_name = request.last_name
    vendor.father_name = request.father_name
    vendor.email = request.email
    if request.email and user.email != request.email:
        existing_email_user = (await db.execute(
            select(User.id).where(User.email == request.email, User.id != user.id)
        )).scalar_one_or_none()
        if not existing_email_user:
            user.email = request.email
            db.add(user)
    vendor.alternative_number = request.alternative_number
    vendor.business_name = request.business_name
    vendor.aadhaar_number = request.aadhaar_number
    vendor.address = request.address
    vendor.city = request.city
    vendor.state = request.state
    vendor.pincode = request.pincode
    vendor.latitude = request.latitude
    vendor.longitude = request.longitude
    vendor.service_radius_km = request.service_radius_km
    vendor.profile_image = request.profile_image
    vendor.status = "active"
    
    # Track which employee onboarded this vendor
    vendor.onboarded_by_employee_id = current_employee.id
    existing_source = (vendor.lead_source or "").strip().lower()
    if existing_source not in ("company", "company_website", "company_mobile"):
        vendor.lead_source = "direct_telecaller"
    if not vendor.assigned_telecaller_id and existing_source in (
        "company",
        "company_website",
        "company_mobile",
    ):
        vendor.assigned_telecaller_id = current_employee.id
    
    db.add(vendor)
    
    # Delete existing categories if any
    await db.execute(delete(VendorSubCategory).where(VendorSubCategory.vendor_id == vendor.id))
    
    # Add Categories
    for cat in request.categories:
        for sub_cat_id in cat.sub_category_ids:
            new_sub_cat = VendorSubCategory(
                vendor_id=vendor.id,
                main_category_id=cat.main_category_id,
                sub_category_id=sub_cat_id
            )
            db.add(new_sub_cat)
            
    # Add referral points to employee

    from datetime import date
    from sqlalchemy import text
    
    current_employee.referral_points += 10
    
    # Update daily points
    today = date.today()
    check_query = text("SELECT id FROM employee_daily_points WHERE employee_id = :emp_id AND date = :today")
    res = await db.execute(check_query, {"emp_id": current_employee.id, "today": today})
    if res.scalar_one_or_none():
        await db.execute(text("UPDATE employee_daily_points SET points = points + 10 WHERE employee_id = :emp_id AND date = :today"), {"emp_id": current_employee.id, "today": today})
    else:
        await db.execute(text("INSERT INTO employee_daily_points (employee_id, date, points) VALUES (:emp_id, :today, 10)"), {"emp_id": current_employee.id, "today": today})

    db.add(current_employee)
            
    await db.commit()
    
    return {
        "message": "Vendor onboarded successfully",
        "vendor_id": vendor.id,
        "points_earned": 10,
        "total_points": current_employee.referral_points
    }

from app.schemas.employee import (
    TelecallerVendorOnboardRequest,
    TelecallerVendorProfileRequest,
    TelecallerCategoryServicesRequest,
    TelecallerDashboardStatsResponse,
    PaginatedOnboardedVendorsResponse,
    TelecallerLeaderboardEntry
)
from app.models.vendor import VendorService
from app.services.otp_service import otp_service
from app.models.catalog import Service


async def _get_or_create_user_and_vendor(mobile: str, db: AsyncSession):
    """Create or fetch User + Vendor for telecaller onboarding."""
    user_query = await db.execute(select(User).where(User.mobile == mobile))
    user = user_query.scalar_one_or_none()

    if not user:
        user = User(
            mobile=mobile,
            email=None,
            role="VENDOR",
            is_active=True,
            otp_verified=True
        )
        db.add(user)
        await db.flush()
    else:
        if not user.role:
            user.role = "VENDOR"
        elif "VENDOR" not in str(user.role):
            user.role = str(user.role) + ",VENDOR"
        db.add(user)
        await db.flush()

    vendor_query = await db.execute(select(Vendor).where(Vendor.user_id == user.id))
    vendor = vendor_query.scalar_one_or_none()

    if vendor and vendor.status == "active":
        raise HTTPException(status_code=400, detail="Vendor is already fully registered")

    if not vendor:
        vendor = Vendor(
            user_id=user.id,
            status="onboarding",
            lead_source="direct_telecaller",
        )
        db.add(vendor)
        await db.flush()

    return user, vendor


def _apply_vendor_profile(vendor: Vendor, request, employee_id: int):
    """Apply profile fields from a request object onto a Vendor."""
    vendor.first_name = request.first_name
    vendor.last_name = request.last_name
    vendor.father_name = request.father_name
    vendor.email = request.email
    vendor.alternative_number = request.alternative_number
    vendor.business_name = request.business_name
    vendor.aadhaar_number = request.aadhaar_number
    vendor.address = request.address
    vendor.city = request.city
    vendor.state = request.state
    vendor.pincode = request.pincode
    vendor.latitude = request.latitude
    vendor.longitude = request.longitude
    vendor.service_radius_km = request.service_radius_km
    vendor.profile_image = request.profile_image
    vendor.status = "onboarding"
    vendor.onboarded_by_employee_id = employee_id
    # Preserve company website/mobile assignment source; only mark direct for true telecaller onboard
    existing_source = (vendor.lead_source or "").strip().lower()
    if existing_source not in ("company", "company_website", "company_mobile"):
        vendor.lead_source = "direct_telecaller"
    if not vendor.assigned_telecaller_id and existing_source in (
        "company",
        "company_website",
        "company_mobile",
    ):
        vendor.assigned_telecaller_id = employee_id


async def _append_categories(vendor: Vendor, categories, db: AsyncSession):
    """Append category selections, skipping duplicates (single query for existing)."""
    requested: set[tuple[int, int]] = set()
    for cat in categories:
        for sub_cat_id in cat.sub_category_ids:
            requested.add((cat.main_category_id, sub_cat_id))

    if not requested:
        return

    existing_result = await db.execute(
        select(VendorSubCategory.main_category_id, VendorSubCategory.sub_category_id).where(
            VendorSubCategory.vendor_id == vendor.id
        )
    )
    existing = {(row[0], row[1]) for row in existing_result.all()}

    for main_category_id, sub_cat_id in requested - existing:
        db.add(VendorSubCategory(
            vendor_id=vendor.id,
            main_category_id=main_category_id,
            sub_category_id=sub_cat_id,
        ))


async def _append_services(vendor: Vendor, services, db: AsyncSession):
    """Append or update vendor services (batched catalog + existing lookups)."""
    if not services:
        return

    service_ids = [srv.service_id for srv in services]
    catalog_result = await db.execute(select(Service).where(Service.id.in_(service_ids)))
    service_map = {s.id: s for s in catalog_result.scalars().all()}

    missing = [sid for sid in service_ids if sid not in service_map]
    if missing:
        raise HTTPException(status_code=404, detail=f"Service ID {missing[0]} not found")

    existing_result = await db.execute(
        select(VendorService).where(
            VendorService.vendor_id == vendor.id,
            VendorService.service_id.in_(service_ids),
        )
    )
    existing_map = {vs.service_id: vs for vs in existing_result.scalars().all()}

    for srv in services:
        service_record = service_map[srv.service_id]
        existing = existing_map.get(service_record.id)

        if existing:
            existing.price = srv.amount
            existing.discounted_price = srv.discounted_amount
            existing.negotiable = srv.is_negotiable
            existing.is_active = True
            db.add(existing)
        else:
            db.add(VendorService(
                vendor_id=vendor.id,
                main_category_id=service_record.main_category_id,
                sub_category_id=service_record.sub_category_id,
                service_id=service_record.id,
                title=service_record.name,
                price=srv.amount,
                discounted_price=srv.discounted_amount,
                negotiable=srv.is_negotiable,
                is_active=True,
            ))


@router.post("/vendors/telecaller-onboard/profile", response_model=dict)
async def telecaller_onboard_profile(
    mobile: str,
    request: TelecallerVendorProfileRequest,
    current_employee: Employee = Depends(get_current_employee),
    db: AsyncSession = Depends(get_db)
):
    """Step 1: Create vendor stub with profile details."""
    _, vendor = await _get_or_create_user_and_vendor(mobile, db)
    _apply_vendor_profile(vendor, request, current_employee.id)
    db.add(vendor)
    await db.commit()

    return {
        "message": "Vendor profile saved successfully",
        "vendor_id": vendor.id,
    }


@router.post("/vendors/telecaller-onboard/category-services", response_model=dict)
async def telecaller_onboard_category_services(
    mobile: str,
    request: TelecallerCategoryServicesRequest,
    current_employee: Employee = Depends(get_current_employee),
    db: AsyncSession = Depends(get_db)
):
    """Step 3: Append categories and services for the current category selection."""
    _, vendor = await _get_or_create_user_and_vendor(mobile, db)

    if not vendor.first_name:
        raise HTTPException(
            status_code=400,
            detail="Vendor profile not found. Complete step 1 first."
        )

    await _append_categories(vendor, request.categories, db)
    await _append_services(vendor, request.services, db)
    await db.commit()

    return {
        "message": "Categories and services saved successfully",
        "vendor_id": vendor.id,
    }


@router.post("/vendors/telecaller-onboard/complete", response_model=dict)
async def telecaller_onboard_complete(
    mobile: str,
    background_tasks: BackgroundTasks,
    current_employee: Employee = Depends(get_current_employee),
    db: AsyncSession = Depends(get_db)
):
    """Step 5: Finalize telecaller onboarding — notify vendor and award referral points."""
    _, vendor = await _get_or_create_user_and_vendor(mobile, db)

    if not vendor.first_name:
        raise HTTPException(
            status_code=400,
            detail="Vendor profile not found. Complete step 1 first."
        )

    vendor.status = "onboarding"
    vendor.onboarded_by_employee_id = current_employee.id
    db.add(vendor)


    from datetime import date
    from sqlalchemy import text
    
    current_employee.referral_points += 10
    
    # Update daily points
    today = date.today()
    check_query = text("SELECT id FROM employee_daily_points WHERE employee_id = :emp_id AND date = :today")
    res = await db.execute(check_query, {"emp_id": current_employee.id, "today": today})
    if res.scalar_one_or_none():
        await db.execute(text("UPDATE employee_daily_points SET points = points + 10 WHERE employee_id = :emp_id AND date = :today"), {"emp_id": current_employee.id, "today": today})
    else:
        await db.execute(text("INSERT INTO employee_daily_points (employee_id, date, points) VALUES (:emp_id, :today, 10)"), {"emp_id": current_employee.id, "today": today})

    db.add(current_employee)
    await db.commit()

    message = "Welcome to AM5 ROYAL! Complete your documentation and KYC to activate your vendor account. Click here: https://vendor.am5royal.com/login This link will redirect you to the vendor portal. Thank you for choosing AM5 ROYAL."
    background_tasks.add_task(
        otp_service.send_custom_sms,
        mobile,
        message,
        tpid="1707178273082121738",
    )

    return {
        "message": "Vendor telecaller onboarding completed successfully",
        "vendor_id": vendor.id,
        "points_earned": 10,
        "total_points": current_employee.referral_points,
    }


@router.post("/vendors/telecaller-onboard", response_model=dict)
async def telecaller_onboard_vendor(
    mobile: str,
    request: TelecallerVendorOnboardRequest,
    background_tasks: BackgroundTasks,
    current_employee: Employee = Depends(get_current_employee),
    db: AsyncSession = Depends(get_db)
):
    """Full telecaller onboard in one call (legacy). Keeps vendor in onboarding status."""
    _, vendor = await _get_or_create_user_and_vendor(mobile, db)
    _apply_vendor_profile(vendor, request, current_employee.id)
    db.add(vendor)

    # Replace all categories and services for full onboard
    await db.execute(delete(VendorSubCategory).where(VendorSubCategory.vendor_id == vendor.id))
    for cat in request.categories:
        for sub_cat_id in cat.sub_category_ids:
            db.add(VendorSubCategory(
                vendor_id=vendor.id,
                main_category_id=cat.main_category_id,
                sub_category_id=sub_cat_id,
            ))

    await db.execute(delete(VendorService).where(VendorService.vendor_id == vendor.id))
    await _append_services(vendor, request.services, db)


    from datetime import date
    from sqlalchemy import text
    
    current_employee.referral_points += 10
    
    # Update daily points
    today = date.today()
    check_query = text("SELECT id FROM employee_daily_points WHERE employee_id = :emp_id AND date = :today")
    res = await db.execute(check_query, {"emp_id": current_employee.id, "today": today})
    if res.scalar_one_or_none():
        await db.execute(text("UPDATE employee_daily_points SET points = points + 10 WHERE employee_id = :emp_id AND date = :today"), {"emp_id": current_employee.id, "today": today})
    else:
        await db.execute(text("INSERT INTO employee_daily_points (employee_id, date, points) VALUES (:emp_id, :today, 10)"), {"emp_id": current_employee.id, "today": today})

    db.add(current_employee)
    await db.commit()

    message = "Welcome to AM5 ROYAL! Complete your documentation and KYC to activate your vendor account. Click here: https://vendor.am5royal.com/login This link will redirect you to the vendor portal. Thank you for choosing AM5 ROYAL."
    background_tasks.add_task(
        otp_service.send_custom_sms,
        mobile,
        message,
        tpid="1707178273082121738",
    )

    return {
        "message": "Vendor fully onboarded successfully",
        "vendor_id": vendor.id,
        "points_earned": 10,
        "total_points": current_employee.referral_points
    }

from typing import Optional
from datetime import date, datetime, timedelta

@router.get("/telecaller-dashboard/stats", response_model=TelecallerDashboardStatsResponse)
async def get_telecaller_stats(
    current_employee: Employee = Depends(get_current_employee),
    db: AsyncSession = Depends(get_db)
):
    from sqlalchemy import text
    today = date.today()
    start_of_week = today - timedelta(days=today.weekday())
    start_of_month = today.replace(day=1)
    
    # weekly onboardings
    weekly_query = text("SELECT COUNT(*) FROM vendors WHERE onboarded_by_employee_id = :emp_id AND created_at >= :start_of_week")
    res_week = await db.execute(weekly_query, {"emp_id": current_employee.id, "start_of_week": start_of_week})
    weekly_onboardings = res_week.scalar() or 0
    
    # monthly onboardings
    monthly_query = text("SELECT COUNT(*) FROM vendors WHERE onboarded_by_employee_id = :emp_id AND created_at >= :start_of_month")
    res_month = await db.execute(monthly_query, {"emp_id": current_employee.id, "start_of_month": start_of_month})
    monthly_conversions = res_month.scalar() or 0
    
    # estimated referral payout (10% of subscription price of all onboarded vendors)
    payout_query = text("""
        SELECT COALESCE(SUM(sp.price), 0)
        FROM vendors v
        JOIN vendor_subscriptions vs ON v.id = vs.vendor_id
        JOIN subscription_plans sp ON vs.subscription_plan_id = sp.id
        WHERE v.onboarded_by_employee_id = :emp_id AND vs.status = 'active'
    """)
    res_payout = await db.execute(payout_query, {"emp_id": current_employee.id})
    estimated_referral_payout = float(res_payout.scalar() or 0.0) * 0.10
    
    # monthly payout bonus (10% of subscription price of vendors onboarded this month)
    monthly_payout_query = text("""
        SELECT COALESCE(SUM(sp.price), 0)
        FROM vendors v
        JOIN vendor_subscriptions vs ON v.id = vs.vendor_id
        JOIN subscription_plans sp ON vs.subscription_plan_id = sp.id
        WHERE v.onboarded_by_employee_id = :emp_id AND vs.status = 'active' AND v.created_at >= :start_of_month
    """)
    res_monthly_payout = await db.execute(monthly_payout_query, {"emp_id": current_employee.id, "start_of_month": start_of_month})
    monthly_payout_bonus = float(res_monthly_payout.scalar() or 0.0) * 0.10

    # Calculate total withdrawn (sum of approved/pending withdrawals)
    withdrawn_query = text("SELECT COALESCE(SUM(amount), 0) FROM withdrawal_requests WHERE employee_id = :emp_id AND status IN ('pending', 'approved')")
    res_withdrawn = await db.execute(withdrawn_query, {"emp_id": current_employee.id})
    total_withdrawn = float(res_withdrawn.scalar() or 0.0)
    
    withdrawable_balance = max(0.0, estimated_referral_payout - total_withdrawn)
    
    # Calculate detailed points
    telecaller_points_query = text("SELECT COALESCE(SUM(points_added), 0) FROM points_history WHERE user_id = :emp_id AND user_type = 'employee' AND reason = 'direct_telecaller_payment'")
    res_tp = await db.execute(telecaller_points_query, {"emp_id": current_employee.id})
    telecaller_points = int(res_tp.scalar() or 0)
    
    company_points_query = text("SELECT COALESCE(SUM(points_added), 0) FROM points_history WHERE user_id = :emp_id AND user_type = 'employee' AND reason = 'company_lead_payment'")
    res_cp = await db.execute(company_points_query, {"emp_id": current_employee.id})
    company_points = int(res_cp.scalar() or 0)
    
    freelancer_points_query = text("""
        SELECT f.first_name, f.last_name, SUM(ph.points_added) as total_points
        FROM points_history ph
        JOIN vendors v ON ph.vendor_id = v.id
        JOIN freelancers f ON v.freelancer_id = f.id
        WHERE ph.user_id = :emp_id AND ph.user_type = 'employee' AND ph.reason = 'freelancer_lead_telecaller_payment'
        GROUP BY f.id, f.first_name, f.last_name
    """)
    res_fp = await db.execute(freelancer_points_query, {"emp_id": current_employee.id})
    freelancer_points_list = []
    for row in res_fp.all():
        name = row[0] if row[0] else "Freelancer"
        if row[1]:
            name += f" {row[1]}"
        freelancer_points_list.append({"name": name, "points": int(row[2])})
        
    return {
        "weekly_onboardings": weekly_onboardings,
        "monthly_conversions": monthly_conversions,
        "referral_points": current_employee.referral_points,
        "estimated_referral_payout": estimated_referral_payout,
        "monthly_payout_bonus": monthly_payout_bonus,
        "withdrawable_balance": withdrawable_balance,
        "total_withdrawn": total_withdrawn,
        "telecaller_points": {"name": current_employee.first_name or "Telecaller", "points": telecaller_points},
        "company_points": {"name": "AM5royal", "points": company_points},
        "freelancer_points": freelancer_points_list
    }


@router.get("/telecaller-dashboard/onboarded", response_model=PaginatedOnboardedVendorsResponse)
async def get_telecaller_onboarded(
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    skip: int = 0,
    limit: int = 50,
    lead_source: Optional[str] = None,
    current_employee: Employee = Depends(get_current_employee),
    db: AsyncSession = Depends(get_db)
):
    from sqlalchemy import text
    
    query_str = """
        SELECT 
            v.id, 
            v.business_name, 
            v.first_name, 
            v.last_name, 
            v.city, 
            v.created_at, 
            u.mobile as mobile_number,
            v.lead_source,
            (
                CASE
                    WHEN v.status = 'rejected' THEN 'rejected'
                    WHEN v.status = 'active' THEN 'active'
                    WHEN v.status = 'temporary_active' THEN 'temporary active'
                    WHEN EXISTS (SELECT 1 FROM vendor_subscriptions vs WHERE vs.vendor_id = v.id AND vs.status = 'active') THEN 'temporary active'
                    WHEN v.business_name IS NOT NULL AND v.business_name != '' THEN 'payment'
                    WHEN v.first_name IS NOT NULL AND v.first_name != '' THEN 'business registration'
                    WHEN EXISTS (SELECT 1 FROM vendor_availability va WHERE va.vendor_id = v.id) THEN 'registration'
                    WHEN EXISTS (SELECT 1 FROM vendor_services v_s WHERE v_s.vendor_id = v.id) THEN 'slots done'
                    ELSE 'services added'
                END
            ) as status
        FROM vendors v
        JOIN users u ON v.user_id = u.id
        WHERE COALESCE(v.status, '') <> 'rejected'
          AND (
            v.onboarded_by_employee_id = :emp_id
            OR v.assigned_telecaller_id = :emp_id
            OR (
                v.status = 'temporary_active'
                AND (
                    v.lead_source IN ('company', 'company_website', 'company_mobile')
                    OR v.lead_source IS NULL
                    OR v.lead_source = ''
                )
            )
          )
    """
    params = {"emp_id": current_employee.id}
    
    if start_date:
        query_str += " AND v.created_at >= :start_date"
        params["start_date"] = start_date
    if end_date:
        # Add 1 day to include the end date fully
        query_str += " AND v.created_at < :end_date"
        params["end_date"] = end_date + timedelta(days=1)

    if lead_source:
        if lead_source == "company_website":
            query_str += " AND (v.lead_source IN ('company_website', 'company') OR v.lead_source IS NULL OR v.lead_source = '')"
        elif lead_source == "company_mobile":
            query_str += " AND v.lead_source = 'company_mobile'"
        elif lead_source == "direct_telecaller":
            query_str += " AND v.lead_source = 'direct_telecaller'"
        else:
            query_str += " AND v.lead_source = :lead_source"
            params["lead_source"] = lead_source
        
    # Count total
    count_query_str = "SELECT COUNT(*) FROM (" + query_str + ") AS sub"
    res_count = await db.execute(text(count_query_str), params)
    total = res_count.scalar() or 0
    
    # Paginated data — Temp Active first so Approve/Reject appear on Website + Application tabs
    query_str += """
        ORDER BY
            CASE WHEN v.status = 'temporary_active' THEN 0 ELSE 1 END,
            (v.lead_source IN ('company', 'company_website', 'company_mobile')) DESC,
            v.created_at DESC
        LIMIT :limit OFFSET :skip
    """
    params["limit"] = limit
    params["skip"] = skip
    
    res = await db.execute(text(query_str), params)
    rows = res.fetchall()
    
    vendors = []
    for row in rows:
        vendors.append({
            "id": row.id,
            "business_name": row.business_name,
            "first_name": row.first_name,
            "last_name": row.last_name,
            "city": row.city,
            "status": row.status,
            "created_at": row.created_at,
            "mobile_number": row.mobile_number or "",
            "lead_source": row.lead_source
        })
        
    return {
        "total": total,
        "vendors": vendors
    }


@router.get("/telecaller-dashboard/vendor-step-details/{vendor_id}")
async def get_vendor_step_details(
    vendor_id: int,
    current_employee: Employee = Depends(get_current_employee),
    db: AsyncSession = Depends(get_db),
):
    """
    Get detailed step breakdown for a vendor:
    - registration (Personal info, contact, location)
    - business_reg (Business name, PAN, Aadhaar, GST, docs)
    - services (Services added with prices & discount prices)
    - slots (Availability & working hours)
    - payment (Subscriptions / payment details)
    """
    from sqlalchemy import text

    vendor_row = (
        await db.execute(
            text(
                """
                SELECT
                    v.id,
                    v.first_name,
                    v.last_name,
                    v.father_name,
                    v.email,
                    v.alternative_number,
                    v.alternative_contact_number,
                    v.city,
                    v.state,
                    v.pincode,
                    v.address,
                    v.created_at,
                    v.business_name,
                    v.aadhaar_number,
                    v.pan_number,
                    v.gst_number,
                    v.service_radius_km,
                    v.payment_info,
                    v.status,
                    v.lead_source,
                    v.onboarded_by_employee_id,
                    v.assigned_telecaller_id,
                    u.mobile AS mobile_number
                FROM vendors v
                JOIN users u ON v.user_id = u.id
                WHERE v.id = :vendor_id
                """
            ),
            {"vendor_id": vendor_id},
        )
    ).mappings().first()

    if not vendor_row:
        raise HTTPException(status_code=404, detail="Vendor not found")

    owned = (
        vendor_row["onboarded_by_employee_id"] == current_employee.id
        or vendor_row["assigned_telecaller_id"] == current_employee.id
    )
    lead_source = (vendor_row["lead_source"] or "").strip().lower()
    is_company_lead = lead_source in (
        "",
        "company",
        "company_website",
        "company_mobile",
    )
    # Same visibility as list: assigned/onboarded OR company Temp Active pool
    status = (vendor_row["status"] or "").strip().lower()
    in_temp_pool = status == "temporary_active" and is_company_lead
    if not owned and not in_temp_pool:
        raise HTTPException(status_code=403, detail="Not allowed to view this vendor")

    docs = (
        await db.execute(
            text(
                """
                SELECT document_type, verification_status, document_url
                FROM vendor_documents
                WHERE vendor_id = :vendor_id
                ORDER BY id DESC
                """
            ),
            {"vendor_id": vendor_id},
        )
    ).mappings().all()

    services = (
        await db.execute(
            text(
                """
                SELECT
                    vs.title,
                    vs.description,
                    vs.price,
                    vs.discounted_price,
                    mc.name AS main_category_name,
                    sc.name AS sub_category_name
                FROM vendor_services vs
                LEFT JOIN main_categories mc ON vs.main_category_id = mc.id
                LEFT JOIN sub_categories sc ON vs.sub_category_id = sc.id
                WHERE vs.vendor_id = :vendor_id
                ORDER BY vs.id DESC
                """
            ),
            {"vendor_id": vendor_id},
        )
    ).mappings().all()

    day_names = {
        0: "Monday",
        1: "Tuesday",
        2: "Wednesday",
        3: "Thursday",
        4: "Friday",
        5: "Saturday",
        6: "Sunday",
    }
    availability = (
        await db.execute(
            text(
                """
                SELECT day_of_week, start_time, end_time, is_available
                FROM vendor_availability
                WHERE vendor_id = :vendor_id
                ORDER BY day_of_week ASC, start_time ASC
                """
            ),
            {"vendor_id": vendor_id},
        )
    ).mappings().all()

    subscriptions = (
        await db.execute(
            text(
                """
                SELECT
                    vs.id,
                    vs.status,
                    vs.start_date,
                    vs.end_date,
                    sp.name AS plan_name,
                    sp.price AS amount
                FROM vendor_subscriptions vs
                LEFT JOIN subscription_plans sp ON vs.subscription_plan_id = sp.id
                WHERE vs.vendor_id = :vendor_id
                ORDER BY vs.id DESC
                """
            ),
            {"vendor_id": vendor_id},
        )
    ).mappings().all()

    def _fmt_time(value):
        if value is None:
            return None
        if hasattr(value, "strftime"):
            return value.strftime("%H:%M")
        return str(value)[:5]

    def _fmt_dt(value):
        if value is None:
            return None
        return value.isoformat() if hasattr(value, "isoformat") else str(value)

    return {
        "registration": {
            "first_name": vendor_row["first_name"],
            "last_name": vendor_row["last_name"],
            "father_name": vendor_row["father_name"],
            "mobile_number": vendor_row["mobile_number"] or "",
            "alternative_contact_number": (
                vendor_row["alternative_contact_number"]
                or vendor_row["alternative_number"]
            ),
            "email": vendor_row["email"],
            "city": vendor_row["city"],
            "state": vendor_row["state"],
            "pincode": vendor_row["pincode"],
            "address": vendor_row["address"],
            "created_at": _fmt_dt(vendor_row["created_at"]),
        },
        "business_reg": {
            "business_name": vendor_row["business_name"],
            "aadhaar_number": vendor_row["aadhaar_number"],
            "pan_number": vendor_row["pan_number"],
            "gst_number": vendor_row["gst_number"],
            "service_radius_km": vendor_row["service_radius_km"] or 10,
            "documents": [
                {
                    "document_type": d["document_type"],
                    "verification_status": d["verification_status"],
                    "document_url": d["document_url"],
                }
                for d in docs
            ],
        },
        "services": [
            {
                "title": s["title"],
                "description": s["description"],
                "price": float(s["price"]) if s["price"] is not None else None,
                "discounted_price": (
                    float(s["discounted_price"])
                    if s["discounted_price"] is not None
                    else None
                ),
                "main_category_name": s["main_category_name"],
                "sub_category_name": s["sub_category_name"],
            }
            for s in services
        ],
        "slots": [
            {
                "day_name": day_names.get(a["day_of_week"], f"Day {a['day_of_week']}"),
                "start_time": _fmt_time(a["start_time"]),
                "end_time": _fmt_time(a["end_time"]),
                "is_available": a["is_available"],
            }
            for a in availability
            if a["is_available"] is not False
        ],
        "payment": {
            "payment_info": vendor_row["payment_info"],
            "subscriptions": [
                {
                    "plan_name": sub["plan_name"] or "Plan",
                    "payment_id": str(sub["id"]),
                    "amount": float(sub["amount"]) if sub["amount"] is not None else 0,
                    "status": sub["status"],
                    "start_date": _fmt_dt(sub["start_date"]),
                    "end_date": _fmt_dt(sub["end_date"]),
                }
                for sub in subscriptions
            ],
        },
    }


@router.get("/telecaller-dashboard/leaderboard", response_model=List[TelecallerLeaderboardEntry])
async def get_telecaller_leaderboard(
    db: AsyncSession = Depends(get_db),
    current_employee: Employee = Depends(get_current_employee)
):
    result = await db.execute(
        select(Employee.first_name, Employee.last_name, Employee.referral_points)
        .where(Employee.role == 'telecaller', Employee.status == 'active')
        .order_by(Employee.referral_points.desc())
        .limit(10)
    )
    rows = result.fetchall()
    return [{"name": f"{r[0]} {r[1] or ''}".strip(), "points": r[2]} for r in rows]


@router.get("/telecaller-dashboard/incentives")
async def get_verification_incentives(
    skip: int = 0,
    limit: int = 100,
    current_employee: Employee = Depends(get_current_employee),
    db: AsyncSession = Depends(get_db),
):
    """Department-wide verification incentive summary (newest first)."""
    from app.models.verification_incentive import VerificationIncentive
    from app.models.subscriptions import SubscriptionPlan

    result = await db.execute(
        select(VerificationIncentive, SubscriptionPlan.name)
        .outerjoin(
            SubscriptionPlan,
            VerificationIncentive.plan_id == SubscriptionPlan.id,
        )
        .order_by(
            VerificationIncentive.payment_date.desc(),
            VerificationIncentive.id.desc(),
        )
        .offset(skip)
        .limit(limit)
    )
    rows = result.all()
    return [
        {
            "id": row.id,
            "vendor_id": row.vendor_id,
            "vendor_name": row.vendor_name,
            "subscription_amount": row.subscription_amount,
            "incentive_percent": row.incentive_percent,
            "incentive_amount": row.incentive_amount,
            "payment_date": row.payment_date.isoformat() if row.payment_date else None,
            "plan_id": row.plan_id,
            "plan_name": plan_name,
            "employee_id": row.employee_id,
        }
        for row, plan_name in rows
    ]


@router.put("/vendors/{vendor_id}/approve", response_model=dict)
async def approve_vendor_by_telecaller(
    vendor_id: int,
    background_tasks: BackgroundTasks,
    current_employee: Employee = Depends(get_current_employee),
    db: AsyncSession = Depends(get_db),
):
    """Allow telecaller to approve temporary_active vendors (assigned or unassigned)."""
    from sqlalchemy import text
    from app.models.vendor import Vendor
    from app.models.user_location import User

    vendor = await db.get(Vendor, vendor_id)
    if not vendor:
        raise HTTPException(status_code=404, detail="Vendor not found")

    old_status = (vendor.status or "").strip().lower()
    has_active_sub = False
    if old_status not in ("temporary_active", "temporary active"):
        sub_res = await db.execute(
            text(
                """
                SELECT 1 FROM vendor_subscriptions
                WHERE vendor_id = :vendor_id AND status = 'active'
                LIMIT 1
                """
            ),
            {"vendor_id": vendor_id},
        )
        has_active_sub = sub_res.first() is not None
        if not has_active_sub:
            raise HTTPException(
                status_code=400,
                detail="Only temporary_active vendors can be approved",
            )

    # Claim unassigned company lead for this telecaller on approve
    if vendor.assigned_telecaller_id is None:
        vendor.assigned_telecaller_id = current_employee.id

    vendor.status = "active"
    db.add(vendor)
    await db.commit()

    user_query = await db.execute(select(User).where(User.id == vendor.user_id))
    user = user_query.scalar_one_or_none()
    if user:
        from app.services.notification_service import send_user_push_notification
        background_tasks.add_task(
            send_user_push_notification,
            user_id=user.id,
            title="Verification Completed",
            body="Your verification is completed. Thank you for choosing AM5Royal.",
        )
        if vendor.lead_source != "company_mobile" and user.mobile:
            from app.services.otp_service import otp_service
            background_tasks.add_task(
                otp_service.send_custom_sms,
                phone=user.mobile,
                message=(
                    "Your verification is completed. Thank you for choosing AM5Royal. "
                    "Your vendor account is now active."
                ),
                tpid="1707178343955979594",
            )

    return {"message": "Vendor approved successfully", "status": "active"}


@router.put("/vendors/{vendor_id}/reject")
async def reject_vendor_by_employee(
    vendor_id: int,
    db: AsyncSession = Depends(get_db),
    current_employee: Employee = Depends(get_current_employee),
):
    """Allow telecaller to reject vendors visible in their dashboard (assigned or unassigned)."""
    result = await db.execute(select(Vendor).where(Vendor.id == vendor_id))
    vendor = result.scalar_one_or_none()
    if not vendor:
        raise HTTPException(status_code=404, detail="Vendor not found")

    if (vendor.status or "").strip().lower() == "active":
        raise HTTPException(
            status_code=400,
            detail="Active vendors cannot be rejected",
        )

    if vendor.assigned_telecaller_id is None:
        vendor.assigned_telecaller_id = current_employee.id

    vendor.status = "rejected"
    await db.commit()
    return {"message": "Vendor rejected successfully", "status": "rejected"}


@router.post("/vendors/send-whatsapp-invite")
async def send_whatsapp_invite(
    request: WhatsAppInviteRequest,
    current_employee: Employee = Depends(get_current_employee)
):
    import httpx
    import re
    invite_link = 'https://vendor.am5royal.com/login'
    message = (
        f"🌟 *Welcome to AM5 ROYAL!* 🌟\n\n"
        f"Dear *{request.vendor_name}*,\n"
        f"Grow your business today by joining AM5 ROYAL as a premium Vendor partner! 🚀\n\n"
        f"👉 *Register & Complete your KYC here:* {invite_link}\n\n"
        f"We look forward to partnering with you!\n"
        f"Team AM5 ROYAL"
    )

    # Format phone number to 10 digits
    formatted_phone = re.sub(r'[^0-9]', '', request.phone_number)
    
    url = "http://103.191.208.115/api/v1/campaign.php"
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer c43123f62f01fc96d818d9ec041f1519",
        "X-API-Secret": "844afe927d9c4e261db680c4e35c76c453feed01d736de14f09dd4dab357720f"
    }
    
    payload = {
        "campaign_type": "WAV",
        "campaign_name": f"Vendor Invitation - {request.vendor_name}",
        "phone_numbers": [formatted_phone],
        "message": message
    }
    
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(url, json=payload, headers=headers, timeout=15.0)
            if response.status_code in [200, 201]:
                res_data = response.json()
                if res_data.get("success") is True:
                    return {"success": True, "message": "WhatsApp invite sent"}
            return {"success": False, "error": response.text}
    except Exception as e:
        return {"success": False, "error": str(e)}

@router.post("/withdraw", response_model=WithdrawalRequestResponse)
async def request_withdrawal(
    request: WithdrawalRequestCreate,
    current_employee: Employee = Depends(get_current_employee),
    db: AsyncSession = Depends(get_db)
):
    from sqlalchemy import text
    
    # 1. Verify that bank details are present
    if not (current_employee.bank_name and current_employee.bank_account_number and current_employee.bank_ifsc_code):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Bank details are missing. Please update your bank details first."
        )
        
    # 2. Check current withdrawable balance
    # Calculate estimated referral payout (same as stats endpoint)
    payout_query = text("""
        SELECT COALESCE(SUM(sp.price), 0)
        FROM vendors v
        JOIN vendor_subscriptions vs ON v.id = vs.vendor_id
        JOIN subscription_plans sp ON vs.subscription_plan_id = sp.id
        WHERE v.onboarded_by_employee_id = :emp_id AND vs.status = 'active'
    """)
    res_payout = await db.execute(payout_query, {"emp_id": current_employee.id})
    estimated_referral_payout = float(res_payout.scalar() or 0.0) * 0.10

    # Calculate total withdrawn (sum of approved/pending withdrawals)
    withdrawn_query = text("SELECT COALESCE(SUM(amount), 0) FROM withdrawal_requests WHERE employee_id = :emp_id AND status IN ('pending', 'approved')")
    res_withdrawn = await db.execute(withdrawn_query, {"emp_id": current_employee.id})
    total_withdrawn = float(res_withdrawn.scalar() or 0.0)
    
    withdrawable_balance = max(0.0, estimated_referral_payout - total_withdrawn)

    if request.amount <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Withdrawal amount must be greater than zero."
        )

    if request.amount > withdrawable_balance:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Insufficient balance. Your current withdrawable balance is ₹{withdrawable_balance:.2f}."
        )
        
    # 3. Create a withdrawal request record
    withdrawal = WithdrawalRequest(
        employee_id=current_employee.id,
        amount=request.amount,
        status="pending",
        bank_name=current_employee.bank_name,
        bank_account_number=current_employee.bank_account_number,
        bank_account_name=current_employee.bank_account_name,
        bank_ifsc_code=current_employee.bank_ifsc_code
    )
    
    db.add(withdrawal)
    await db.commit()
    await db.refresh(withdrawal)
    return withdrawal

@router.get("/withdrawals", response_model=List[WithdrawalRequestResponse])
async def list_employee_withdrawals(
    current_employee: Employee = Depends(get_current_employee),
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(WithdrawalRequest)
        .where(WithdrawalRequest.employee_id == current_employee.id)
        .order_by(WithdrawalRequest.created_at.desc())
    )
    return result.scalars().all()



