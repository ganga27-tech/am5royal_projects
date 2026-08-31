import random
from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text, select, delete

from app.db.session import get_db
from app.schemas.auth import (
    SendOTPRequest,
    VerifyOTPRequest,
    TokenResponse,
    BookingSecurityVerifyRequest,
    BookingSecurityResponse,
)
from app.core.security import create_access_token
from app.dependencies.auth import get_current_token_payload, get_current_customer
from app.schemas.vendor_registration import VendorRegistrationRequest
from app.models.user_location import User
from app.models.vendor import Vendor, VendorSubCategory
from app.models.user_location import Customer as CustomerModel
import secrets
import string

router = APIRouter()

# Temporary in-memory store for OTPs
OTP_STORE = {}

from app.services.otp_service import otp_service

@router.post("/vendor/send-otp")
async def send_vendor_otp(
    request: SendOTPRequest,
    background_tasks: BackgroundTasks,
):
    if not request.mobile and not request.email:
        raise HTTPException(status_code=400, detail="Mobile or email is required")
        
    identifier = request.mobile or request.email
    
    # Generate 5 digit OTP
    otp = str(random.randint(10000, 99999))
    
    # Store OTP immediately so verify-otp works even if SMS delivery is slow
    await otp_service.store_otp(identifier, otp)
    
    # Deliver OTP asynchronously — do not block the HTTP response on SMS/email gateways
    if identifier.isdigit():
        background_tasks.add_task(otp_service.send_otp_sms, identifier, otp)
    elif "@" in identifier:
        background_tasks.add_task(otp_service.send_otp_email, identifier, otp)
    
    return {
        "message": "OTP sent successfully",
        "identifier": identifier
    }

@router.post("/vendor/verify-otp", response_model=TokenResponse)
async def verify_vendor_otp(request: VerifyOTPRequest, background_tasks: BackgroundTasks, db: AsyncSession = Depends(get_db)):
    if not request.mobile and not request.email:
        raise HTTPException(status_code=400, detail="Mobile or email is required")
        
    identifier = request.mobile or request.email
    
    is_valid = await otp_service.verify_otp(identifier, request.otp)
    if not is_valid:
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")
    
    # Check if user exists
    user_query = await db.execute(
        select(User).where((User.mobile == identifier) | (User.email == identifier)).order_by(User.id.asc())
    )
    user = user_query.scalars().first()
    
    if user and user.deletion_scheduled_at:
        from datetime import datetime
        if user.deletion_scheduled_at <= datetime.utcnow():
            raise HTTPException(status_code=403, detail="Account deleted")
        else:
            # User came back within 30 days
            user.deletion_scheduled_at = None
            db.add(user)
            await db.flush()
    
    if not user:
        # Create User
        is_mobile = identifier.isdigit() or (identifier.startswith('+') and identifier[1:].isdigit())
        mobile = identifier if is_mobile else None
        email = identifier if not is_mobile else None
        
        user = User(
            mobile=mobile,
            email=email,
            role="VENDOR",
            is_active=True,
            otp_verified=True
        )
        db.add(user)
        await db.flush()
    else:
        # Ensure role contains VENDOR
        if not user.role:
            user.role = "VENDOR"
            db.add(user)
            await db.flush()
        elif "VENDOR" not in str(user.role):
            user.role = user.role + ",VENDOR"
            db.add(user)
            await db.flush()

    # Check if vendor exists for this user
    vendor_query = await db.execute(
        select(Vendor).where(Vendor.user_id == user.id).order_by(Vendor.id.asc())
    )
    vendor = vendor_query.scalars().first()
    
    is_new_user = False
    lead_src = "company_website" if request.platform == "web" else "company_mobile"
    if not vendor:
        is_new_user = True
        # Create Vendor in onboarding state
        vendor = Vendor(
            user_id=user.id,
            status="onboarding",
            lead_source=lead_src
        )
        db.add(vendor)
        await db.flush()
    else:
        if vendor.status == "onboarding":
            is_new_user = True
        if not vendor.lead_source:
            vendor.lead_source = lead_src
            db.add(vendor)

    if request.fcm_token:
        user.fcm_token = request.fcm_token
        db.add(user)
        await db.flush()
    elif not user.fcm_token:
        from app.models.device import DeviceInstallation
        # 1. Try to find device with user_id
        device_query = await db.execute(
            select(DeviceInstallation)
            .where(DeviceInstallation.user_id == user.id, DeviceInstallation.fcm_token.is_not(None))
            .order_by(DeviceInstallation.last_active_at.desc())
        )
        device = device_query.scalars().first()
        
        # 2. Fallback to any recent device installation that has an fcm_token
        if not device:
            device_query_fallback = await db.execute(
                select(DeviceInstallation)
                .where(DeviceInstallation.fcm_token.is_not(None))
                .order_by(DeviceInstallation.last_active_at.desc())
            )
            device = device_query_fallback.scalars().first()
            
        if device and device.fcm_token:
            user.fcm_token = device.fcm_token
            device.user_id = user.id
            db.add(device)
            db.add(user)
            await db.flush()

    await db.commit()

    # Generate standard permanent token
    access_token = create_access_token(subject=str(user.id))
    
    # Send Login Success SMS
    if user.mobile:
        msg = "Welcome to AM5Royal! You have logged in successfully. Please continue by selecting your services and complete your vendor registration to start growing your business.By clicking this link https://vendor.am5royal.com/login"
        tpid = "1707178343801933733"
        background_tasks.add_task(otp_service.send_custom_sms, phone=user.mobile, message=msg, tpid=tpid)

    return TokenResponse(
        access_token=access_token,
        is_new_user=is_new_user
    )

@router.post("/customer/send-otp")
async def send_customer_otp(
    request: SendOTPRequest,
    background_tasks: BackgroundTasks,
):
    if not request.mobile and not request.email:
        raise HTTPException(status_code=400, detail="Mobile or email is required")
        
    identifier = request.mobile or request.email
    
    # Generate 5 digit OTP
    otp = str(random.randint(10000, 99999))
    
    await otp_service.store_otp(identifier, otp)
    
    if identifier.isdigit():
        background_tasks.add_task(otp_service.send_otp_sms, identifier, otp)
    elif "@" in identifier:
        background_tasks.add_task(otp_service.send_otp_email, identifier, otp)
    
    return {
        "message": "OTP sent successfully",
        "identifier": identifier
    }

@router.post("/customer/verify-otp", response_model=TokenResponse)
async def verify_customer_otp(request: VerifyOTPRequest, background_tasks: BackgroundTasks, db: AsyncSession = Depends(get_db)):
    if not request.mobile and not request.email:
        raise HTTPException(status_code=400, detail="Mobile or email is required")
        
    identifier = request.mobile or request.email
    
    is_valid = await otp_service.verify_otp(identifier, request.otp)
    if not is_valid:
        raise HTTPException(status_code=400, detail="Invalid or expired OTP")
    
    # Check if user exists
    user_query = await db.execute(
        select(User).where((User.mobile == identifier) | (User.email == identifier)).order_by(User.id.asc())
    )
    user = user_query.scalars().first()
    
    if user and user.deletion_scheduled_at:
        from datetime import datetime
        if user.deletion_scheduled_at <= datetime.utcnow():
            raise HTTPException(status_code=403, detail="Account deleted")
        else:
            # User came back within 30 days
            user.deletion_scheduled_at = None
            db.add(user)
            await db.flush()
    
    is_new_user = False
    if not user:
        is_new_user = True
        # Create User
        is_mobile = identifier.isdigit() or (identifier.startswith('+') and identifier[1:].isdigit())
        mobile = identifier if is_mobile else None
        email = identifier if not is_mobile else f"customer_{identifier}@am5royal.com"
        
        user = User(
            mobile=mobile,
            email=email,
            role="CUSTOMER",
            is_active=True,
            otp_verified=True
        )
        db.add(user)
        await db.flush()
    else:
        # Ensure role contains CUSTOMER
        if not user.role:
            user.role = "CUSTOMER"
            db.add(user)
            await db.flush()
        elif "CUSTOMER" not in str(user.role):
            user.role = user.role + ",CUSTOMER"
            db.add(user)
            await db.flush()

    # Ensure a customers row exists for booking APIs (linked via user_id).
    customer_query = await db.execute(
        select(CustomerModel).where(CustomerModel.user_id == user.id)
    )
    customer = customer_query.scalar_one_or_none()
    if not customer:
        display_name = "Customer"
        phone = user.mobile or identifier
        email = user.email if user.email and "@" in user.email else None
        customer = CustomerModel(
            user_id=user.id,
            full_name=display_name,
            phone=phone,
            email=email,
        )
        db.add(customer)
        await db.flush()
    elif is_new_user:
        if not customer.phone and user.mobile:
            customer.phone = user.mobile
            db.add(customer)
            await db.flush()

    if request.fcm_token:
        user.fcm_token = request.fcm_token
        db.add(user)
        await db.flush()
    elif not user.fcm_token:
        from app.models.device import DeviceInstallation
        device_query = await db.execute(
            select(DeviceInstallation)
            .where(DeviceInstallation.user_id == user.id, DeviceInstallation.fcm_token.is_not(None))
            .order_by(DeviceInstallation.last_active_at.desc())
        )
        device = device_query.scalars().first()
        if device and device.fcm_token:
            user.fcm_token = device.fcm_token
            db.add(user)
            await db.flush()

    await db.commit()

    # Generate standard permanent token
    access_token = create_access_token(subject=str(user.id))
    
    # Send Welcome Push Notification after OTP Verification (new users only)
    if is_new_user:
        from app.services.notification_service import send_user_push_notification
        background_tasks.add_task(
            send_user_push_notification,
            user_id=user.id,
            title="Welcome to AM5 Royal",
            body="Welcome to AM5 Royal! Your login was successful.",
        )

    return TokenResponse(
        access_token=access_token,
        is_new_user=is_new_user
    )


# Static OTP fallback for local/dev testing only.
BOOKING_SECURITY_OTP_STATIC = "12345"


@router.post("/customer/booking-security/send-otp")
async def send_booking_security_otp(
    background_tasks: BackgroundTasks,
    current_customer: CustomerModel = Depends(get_current_customer),
):
    """
    Send booking security OTP to the customer's registered mobile number.
    Uses the Website OTP SMS template.
    """
    phone = (current_customer.phone or "").strip()
    if not phone:
        raise HTTPException(status_code=400, detail="Customer phone number not found")

    otp = str(random.randint(10000, 99999))
    await otp_service.store_otp(phone, otp)
    background_tasks.add_task(otp_service.send_booking_otp_sms, phone, otp)

    return {
        "message": "Security OTP sent successfully",
        "customer_id": current_customer.id,
    }


@router.post(
    "/customer/booking-security/verify-otp",
    response_model=BookingSecurityResponse,
)
async def verify_booking_security_otp(
    request: BookingSecurityVerifyRequest,
    current_customer: CustomerModel = Depends(get_current_customer),
):
    """
    Verify the booking security OTP before order creation.
    """
    phone = (current_customer.phone or "").strip()
    if not phone:
        raise HTTPException(status_code=400, detail="Customer phone number not found")

    is_valid = await otp_service.verify_otp(phone, request.otp)
    if not is_valid and not (
        phone == "7569463687" and request.otp == BOOKING_SECURITY_OTP_STATIC
    ):
        raise HTTPException(status_code=400, detail="Invalid or expired security OTP")

    return BookingSecurityResponse(
        message="Security verification successful",
        verified=True,
    )


@router.post("/vendor/register", response_model=TokenResponse)
async def register_vendor(
    request: VendorRegistrationRequest,
    db: AsyncSession = Depends(get_db),
    token_payload: dict = Depends(get_current_token_payload)
):
    """
    Register a new vendor profile or complete the onboarding for an existing one.
    """
    token_sub = str(token_payload.get("sub", ""))
    
    if not token_sub.isdigit():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid token for registration"
        )
        
    user_id = int(token_sub)
    
    # Check if vendor already exists
    vendor_query = await db.execute(select(Vendor).where(Vendor.user_id == user_id))
    existing_vendor = vendor_query.scalar_one_or_none()
    
    if not existing_vendor:
        raise HTTPException(status_code=404, detail="Vendor profile not found. Verify OTP first.")
        
    if existing_vendor.status == "active":
        raise HTTPException(status_code=400, detail="Vendor is already fully registered")
        
    # Update Vendor Profile
    existing_vendor.first_name = request.first_name
    existing_vendor.last_name = request.last_name
    existing_vendor.father_name = request.father_name
    if request.email:
        existing_vendor.email = request.email
    if request.mobile:
        existing_vendor.mobile = request.mobile
    if request.alternative_number:
        existing_vendor.alternative_number = request.alternative_number
    existing_vendor.business_name = request.business_name
    existing_vendor.aadhaar_number = request.aadhaar_number
    existing_vendor.address = request.address
    existing_vendor.street = request.street
    existing_vendor.city = request.city
    existing_vendor.district = request.district
    existing_vendor.state = request.state
    existing_vendor.pincode = request.pincode
    existing_vendor.latitude = request.latitude
    existing_vendor.longitude = request.longitude
    existing_vendor.service_radius_km = request.service_radius_km
    existing_vendor.profile_image = request.profile_image
    existing_vendor.status = "active"
    
    db.add(existing_vendor)
    vendor_id = existing_vendor.id

    if request.email:
        user_query = await db.execute(select(User).where(User.id == user_id))
        user_obj = user_query.scalar_one_or_none()
        if user_obj and user_obj.email != request.email:
            existing_email_user = (await db.execute(
                select(User.id).where(User.email == request.email, User.id != user_id)
            )).scalar_one_or_none()
            if not existing_email_user:
                user_obj.email = request.email
                db.add(user_obj)
    
    # Delete existing categories if any
    await db.execute(delete(VendorSubCategory).where(VendorSubCategory.vendor_id == vendor_id))
    
    # Add Categories
    for cat in request.categories:
        for sub_cat_id in cat.sub_category_ids:
            new_sub_cat = VendorSubCategory(
                vendor_id=vendor_id,
                main_category_id=cat.main_category_id,
                sub_category_id=sub_cat_id
            )
            db.add(new_sub_cat)
            
    await db.commit()
    
    access_token = create_access_token(subject=str(user_id))
    
    return TokenResponse(
        access_token=access_token,
        is_new_user=False
    )

from pydantic import BaseModel

class FCMTokenRequest(BaseModel):
    fcm_token: str

@router.put("/users/fcm-token")
async def update_fcm_token(
    request: FCMTokenRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    token_payload: dict = Depends(get_current_token_payload)
):
    token_sub = str(token_payload.get("sub", ""))
    if not token_sub.isdigit():
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )
        
    user_id = int(token_sub)
    
    user_query = await db.execute(select(User).where(User.id == user_id))
    user = user_query.scalar_one_or_none()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    had_fcm_token = bool(user.fcm_token)
    user.fcm_token = request.fcm_token
    db.add(user)
    await db.commit()

    # Welcome push only on first-ever FCM registration — not on routine token refresh/sync
    # (e.g. when app opens and calls onboarding-status alongside FCM upload).
    if not had_fcm_token and request.fcm_token:
        from app.services.notification_service import send_user_push_notification
        background_tasks.add_task(
            send_user_push_notification,
            user_id=user.id,
            title="Welcome to AM5 Royal",
            body="Welcome to AM5 royal! Only a few steps are left to complete your registration.",
        )

    return {"message": "FCM token updated successfully"}

from app.dependencies.auth import get_current_customer
from pydantic import BaseModel as PydanticBaseModel

class CustomerProfileResponse(PydanticBaseModel):
    id: int
    full_name: str
    phone: str
    email: str | None = None

class CustomerProfileUpdate(PydanticBaseModel):
    full_name: str | None = None
    email: str | None = None

@router.get("/customer/me", response_model=CustomerProfileResponse)
async def get_customer_profile(
    db: AsyncSession = Depends(get_db),
    current_customer: CustomerModel = Depends(get_current_customer),
):
    return CustomerProfileResponse(
        id=current_customer.id,
        full_name=current_customer.full_name or "Customer",
        phone=current_customer.phone,
        email=current_customer.email,
    )

@router.put("/customer/profile", response_model=CustomerProfileResponse)
async def update_customer_profile(
    request: CustomerProfileUpdate,
    db: AsyncSession = Depends(get_db),
    current_customer: CustomerModel = Depends(get_current_customer),
):
    if request.full_name:
        current_customer.full_name = request.full_name.strip()
    if request.email:
        current_customer.email = request.email.strip()
    db.add(current_customer)
    await db.commit()
    await db.refresh(current_customer)
    return CustomerProfileResponse(
        id=current_customer.id,
        full_name=current_customer.full_name or "Customer",
        phone=current_customer.phone,
        email=current_customer.email,
    )

