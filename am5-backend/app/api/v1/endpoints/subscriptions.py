from typing import List
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, literal, String
from datetime import datetime, timedelta

from app.db.session import get_db
from app.models.vendor import Vendor, VendorSubCategory, VendorService
from app.models.user_location import City
from app.dependencies.auth import get_current_vendor, get_current_token_payload
from app.models.subscriptions import SubscriptionPlan, VendorSubscription
from app.schemas.subscriptions import SubscriptionPlanResponse, PurchasePlanRequest, VerifyPaymentRequest, RecoverPaymentRequest, VendorSubscriptionResponse
import structlog

logger = structlog.get_logger()
from sqlalchemy.orm import joinedload
from app.services.otp_service import otp_service
from app.workers.cron_jobs import scheduler
from app.models.user_location import User
import razorpay

# Using the API keys provided by the user
RAZORPAY_KEY_ID = "rzp_live_TKoWIICulRFoyv"
RAZORPAY_KEY_SECRET = "fZe5TqxqI0x466ccH8Z5Q1HT"
rzp_client = razorpay.Client(auth=(RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET))

async def resolve_vendor_city_tier(db: AsyncSession, vendor: Vendor) -> str:
    """
    Multi-layer city tier resolver to handle name mismatches (e.g. Cuddapah vs Kadapa),
    aliases, pincodes, and lat/long distance calculation.
    """
    if not vendor:
        return "Tier-1"

    # Layer 1: Direct exact name match
    if vendor.city and vendor.city.strip():
        clean_city = vendor.city.strip().lower()
        
        # Exact match
        city_res = await db.execute(select(City).where(func.lower(City.name) == clean_city))
        city = city_res.scalar_one_or_none()
        if city and city.tier:
            return city.tier

        # Layer 2: Substring / ILIKE match
        city_res = await db.execute(
            select(City).where(
                (func.lower(City.name).contains(clean_city)) |
                (literal(clean_city).contains(func.lower(City.name)))
            )
        )
        city = city_res.scalar_one_or_none()
        if city and city.tier:
            return city.tier

        # Layer 3: Alias match using text/JSON search in City.aliases
        alias_res = await db.execute(
            select(City).where(
                func.cast(City.aliases, String).ilike(f"%{clean_city}%")
            )
        )
        city = alias_res.scalar_one_or_none()
        if city and city.tier:
            return city.tier

        import json
        all_cities_res = await db.execute(select(City).where(City.aliases.isnot(None)))
        all_cities = all_cities_res.scalars().all()
        for c in all_cities:
            if c.aliases:
                aliases_raw = c.aliases
                if isinstance(aliases_raw, str):
                    try:
                        aliases_list = json.loads(aliases_raw)
                    except Exception:
                        aliases_list = [aliases_raw]
                elif isinstance(aliases_raw, list):
                    aliases_list = aliases_raw
                else:
                    aliases_list = []
                for alias in aliases_list:
                    alias_clean = str(alias).strip().lower()
                    if alias_clean == clean_city or alias_clean in clean_city or clean_city in alias_clean:
                        if c.tier:
                            return c.tier

    # Layer 4: Pincode Prefix Match if vendor.pincode exists
    if vendor.pincode and len(vendor.pincode.strip()) >= 3:
        pin_prefix = vendor.pincode.strip()[:3]
        all_cities_res = await db.execute(select(City).where(City.pincodes.isnot(None)))
        all_cities = all_cities_res.scalars().all()
        for c in all_cities:
            if c.pincodes and pin_prefix in c.pincodes:
                if c.tier:
                    return c.tier

    # Layer 5: Geographic Distance Match (Lat/Lng Euclidian Distance)
    if vendor.latitude and vendor.longitude:
        try:
            v_lat = float(vendor.latitude)
            v_lng = float(vendor.longitude)
            
            geo_res = await db.execute(
                select(City).where(
                    City.latitude.isnot(None), 
                    City.longitude.isnot(None)
                ).order_by(
                    (City.latitude - v_lat) * (City.latitude - v_lat) +
                    (City.longitude - v_lng) * (City.longitude - v_lng)
                ).limit(1)
            )
            nearest_city = geo_res.scalar_one_or_none()
            if nearest_city and nearest_city.tier:
                return nearest_city.tier
        except Exception:
            pass

    # Layer 6: Default Fallback
    return "Tier-1"

async def process_vendor_points(db: AsyncSession, vendor: Vendor):
    from app.models.employee import Employee
    from app.models.freelancer import Freelancer
    from app.models.points_history import PointsHistory
    
    if vendor.lead_source == 'direct_telecaller' and vendor.onboarded_by_employee_id:
        emp_res = await db.execute(select(Employee).where(Employee.id == vendor.onboarded_by_employee_id))
        emp = emp_res.scalar_one_or_none()
        if emp:
            emp.total_points = (emp.total_points or 0) + 10
            db.add(PointsHistory(user_id=emp.id, user_type='employee', points_added=10, vendor_id=vendor.id, reason='direct_telecaller_payment'))
            
    elif vendor.lead_source in ('company', 'company_website', 'company_mobile') and vendor.assigned_telecaller_id:
        emp_res = await db.execute(select(Employee).where(Employee.id == vendor.assigned_telecaller_id))
        emp = emp_res.scalar_one_or_none()
        if emp:
            emp.total_points = (emp.total_points or 0) + 5
            db.add(PointsHistory(user_id=emp.id, user_type='employee', points_added=5, vendor_id=vendor.id, reason='company_lead_payment'))
            
    elif vendor.lead_source == 'freelancer' and vendor.freelancer_id:
        free_res = await db.execute(select(Freelancer).where(Freelancer.id == vendor.freelancer_id))
        free = free_res.scalar_one_or_none()
        
        if vendor.assigned_telecaller_id:
            emp_res = await db.execute(select(Employee).where(Employee.id == vendor.assigned_telecaller_id))
            emp = emp_res.scalar_one_or_none()
            if emp:
                emp.total_points = (emp.total_points or 0) + 3
                db.add(PointsHistory(user_id=emp.id, user_type='employee', points_added=3, vendor_id=vendor.id, reason='freelancer_lead_telecaller_payment'))
            if free:
                free.total_points = (free.total_points or 0) + 2
                db.add(PointsHistory(user_id=free.id, user_type='freelancer', points_added=2, vendor_id=vendor.id, reason='freelancer_lead_telecaller_payment'))
        else:
            if free:
                free.total_points = (free.total_points or 0) + 10
                db.add(PointsHistory(user_id=free.id, user_type='freelancer', points_added=10, vendor_id=vendor.id, reason='freelancer_direct_payment'))


def _incentive_percent_for_plan(plan: SubscriptionPlan) -> float:
    """Map plan name to verification incentive percent. Limited/Gold -> 2%, Unlimited/Platinum -> 5%."""
    name = (plan.name or "").lower()
    if "unlimited" in name or "platinum" in name:
        return 5.0
    if "limited" in name or "gold" in name:
        return 2.0
    return 0.0


async def record_verification_incentive(
    db: AsyncSession,
    vendor: Vendor,
    plan: SubscriptionPlan,
    payment_date: datetime,
) -> None:
    from app.models.verification_incentive import VerificationIncentive

    percent = _incentive_percent_for_plan(plan)
    if percent <= 0:
        return

    amount = float(plan.price or 0)
    incentive_amount = round(amount * percent / 100.0, 2)
    vendor_name = (vendor.business_name or "").strip() or (
        f"{(vendor.first_name or '').strip()} {(vendor.last_name or '').strip()}".strip()
        or f"Vendor #{vendor.id}"
    )
    employee_id = vendor.assigned_telecaller_id or vendor.onboarded_by_employee_id

    # Idempotent: one incentive row per vendor+plan activation window (same plan, same day)
    existing = await db.execute(
        select(VerificationIncentive).where(
            VerificationIncentive.vendor_id == vendor.id,
            VerificationIncentive.plan_id == plan.id,
            VerificationIncentive.payment_date >= payment_date.replace(hour=0, minute=0, second=0, microsecond=0),
        )
    )
    if existing.scalar_one_or_none():
        return

    db.add(
        VerificationIncentive(
            vendor_id=vendor.id,
            vendor_name=vendor_name,
            subscription_amount=amount,
            incentive_percent=percent,
            incentive_amount=incentive_amount,
            payment_date=payment_date,
            plan_id=plan.id,
            employee_id=employee_id,
        )
    )

async def trigger_subscription_success_sms(vendor: Vendor, db: AsyncSession, background_tasks: BackgroundTasks):
    user_query = await db.execute(select(User).where(User.id == vendor.user_id))
    user = user_query.scalar_one_or_none()
    if user:
        if user.mobile:
            tpid_success = "1707178343937255237"
            msg_success = "Congratulations! Your payment has been completed successfully. Welcome to the AM5Royal family. Your vendor account has been activated successfully. check through this link https://vendor.am5royal.com/login"
            background_tasks.add_task(otp_service.send_custom_sms, phone=user.mobile, message=msg_success, tpid=tpid_success)
            
            tpid_welcome = "1707178343955979594"
            msg_welcome = "Welcome to AM5Royal! Your registration process is now complete. Your account is active, and you are ready to receive customer enquiries and grow your business with AM5Royal. To check your profile by clicking on this link https://vendor.am5royal.com/login Thank you for choosing AM5Royal. We wish you great success!"
            run_time = datetime.now() + timedelta(minutes=10)
            scheduler.add_job(
                otp_service.send_custom_sms,
                'date',
                run_date=run_time,
                kwargs={'phone': user.mobile, 'message': msg_welcome, 'tpid': tpid_welcome},
            )
        
        # Send Push Notification (1 time after completed payment)
        from app.services.notification_service import send_user_push_notification
        background_tasks.add_task(
            send_user_push_notification,
            user_id=user.id,
            title="Account Temporarily Activated",
            body="Your account has been temporarily activated. To complete your final account activation, please answer the verification call from the AM5Royal verification team. Once verified, your account will be fully activated."
        )

router = APIRouter()

async def _get_active_subscription(db: AsyncSession, vendor_id: int):
    active_sub_query = select(VendorSubscription).where(
        VendorSubscription.vendor_id == vendor_id,
        VendorSubscription.status == "active",
    )
    active_sub_res = await db.execute(active_sub_query)
    return active_sub_res.scalar_one_or_none()


async def _get_active_plan(
    db: AsyncSession, vendor_id: int
) -> tuple[VendorSubscription | None, SubscriptionPlan | None]:
    active_sub = await _get_active_subscription(db, vendor_id)
    if not active_sub:
        return None, None

    plan_query = select(SubscriptionPlan).where(
        SubscriptionPlan.id == active_sub.subscription_plan_id
    )
    plan_res = await db.execute(plan_query)
    current_plan = plan_res.scalar_one_or_none()
    return active_sub, current_plan


def _plan_price(plan: SubscriptionPlan) -> float:
    return float(plan.price or 0)


async def _validate_plan_purchase(
    db: AsyncSession, vendor_id: int, new_plan: SubscriptionPlan
) -> VendorSubscription | None:
    """
    Validates whether a vendor can purchase the given plan.
    Returns the active subscription when this purchase is an upgrade.
    """
    active_sub, current_plan = await _get_active_plan(db, vendor_id)
    if not active_sub or not current_plan:
        return None

    new_price = _plan_price(new_plan)
    current_price = _plan_price(current_plan)

    if new_plan.id == current_plan.id:
        raise HTTPException(
            status_code=400,
            detail="You are already subscribed to this plan.",
        )
    if new_price < current_price:
        raise HTTPException(
            status_code=400,
            detail=(
                "Downgrading to a lower plan is not allowed. "
                "You can only upgrade to a higher plan."
            ),
        )
    return active_sub


async def _activate_vendor_subscription(
    db: AsyncSession,
    vendor: Vendor,
    plan: SubscriptionPlan,
    background_tasks: BackgroundTasks,
    replace_sub: VendorSubscription | None = None,
    is_upgrade: bool = False,
) -> dict:
    now = datetime.utcnow()
    if replace_sub:
        replace_sub.status = "replaced"
        replace_sub.end_date = now
        db.add(replace_sub)

    start_date = now
    end_date = start_date + timedelta(days=plan.validity_days)

    new_sub = VendorSubscription(
        vendor_id=vendor.id,
        subscription_plan_id=plan.id,
        start_date=start_date,
        end_date=end_date,
        status="active",
    )

    db.add(new_sub)
    vendor.status = "temporary_active"
    db.add(vendor)

    try:
        await process_vendor_points(db, vendor)
    except Exception as exc:
        logger.error("points_processing_failed", error=str(exc))

    try:
        await record_verification_incentive(db, vendor, plan, now)
    except Exception as exc:
        logger.error("verification_incentive_failed", error=str(exc))

    try:
        if not is_upgrade:
            await trigger_subscription_success_sms(vendor, db, background_tasks)
    except Exception as exc:
        logger.error("subscription_sms_failed", error=str(exc))

    await db.commit()

    message = (
        "Payment verified and subscription upgraded successfully"
        if is_upgrade
        else "Payment verified and subscription activated successfully"
    )

    return {
        "message": message,
        "vendor_id": vendor.id,
        "plan_name": plan.name,
        "validity_days": plan.validity_days,
        "end_date": end_date.isoformat(),
        "is_upgrade": is_upgrade,
    }


async def _subscription_already_active_response(
    db: AsyncSession, vendor: Vendor, active_sub: VendorSubscription
) -> dict:
    plan = active_sub.plan
    if not plan:
        plan_query = select(SubscriptionPlan).where(
            SubscriptionPlan.id == active_sub.subscription_plan_id
        )
        plan_res = await db.execute(plan_query)
        plan = plan_res.scalar_one_or_none()

    return {
        "message": "Subscription already active",
        "vendor_id": vendor.id,
        "plan_name": plan.name if plan else "Active Plan",
        "validity_days": plan.validity_days if plan else 0,
        "end_date": active_sub.end_date.isoformat() if active_sub.end_date else None,
    }

@router.get("/", response_model=List[SubscriptionPlanResponse])
async def get_subscription_plans(
    db: AsyncSession = Depends(get_db),
    token_payload: dict = Depends(get_current_token_payload)
):
    """
    Fetches all active subscription plans, filtered by the vendor's tier and category count.
    """
    user_id_str = token_payload.get("sub")
    if not user_id_str:
        raise HTTPException(status_code=401, detail="Invalid token payload")
        
    try:
        user_id = int(user_id_str)
    except ValueError:
        raise HTTPException(status_code=401, detail="Invalid user ID in token")

    # Fetch corresponding vendor
    vendor_query = select(Vendor).where(Vendor.user_id == user_id)
    vendor_res = await db.execute(vendor_query)
    vendor = vendor_res.scalar_one_or_none()
    
    if not vendor:
        raise HTTPException(status_code=404, detail="Vendor not found")

    # Determine vendor's city tier using multi-layer resolver (name, aliases, pincode, lat/lng distance)
    vendor_tier = await resolve_vendor_city_tier(db, vendor)

    # Check category count (Single vs Multiple)
    subcat_query1 = select(VendorSubCategory.sub_category_id).where(VendorSubCategory.vendor_id == vendor.id)
    subcat_res1 = await db.execute(subcat_query1)
    subcats1 = subcat_res1.scalars().all()

    subcat_query2 = select(VendorService.sub_category_id).where(VendorService.vendor_id == vendor.id, VendorService.is_active == True)
    subcat_res2 = await db.execute(subcat_query2)
    subcats2 = subcat_res2.scalars().all()
    
    unique_subcats = set(subcats1) | set(subcats2)
    
    plan_type = "single_category"
    if len(unique_subcats) > 1:
        plan_type = "multi_category"

    # Query active plans matching vendor's tier and category plan type
    query = select(SubscriptionPlan).where(
        SubscriptionPlan.is_active == True,
        (SubscriptionPlan.tier == vendor_tier) & (SubscriptionPlan.plan_type == plan_type)
    )

    if plan_type == "single_category" and unique_subcats:
        from app.models.catalog import ServiceSubcategory
        subcat_id = list(unique_subcats)[0]
        subcat_query = select(ServiceSubcategory).where(ServiceSubcategory.id == subcat_id)
        subcat_res = await db.execute(subcat_query)
        subcat = subcat_res.scalar_one_or_none()
        if subcat and subcat.category_type:
            query = select(SubscriptionPlan).where(
                SubscriptionPlan.is_active == True,
                (SubscriptionPlan.tier == vendor_tier) & 
                (SubscriptionPlan.plan_type == plan_type) & 
                (SubscriptionPlan.category_type == subcat.category_type)
            )

    result = await db.execute(query)
    plans = result.scalars().all()
    return plans


@router.get("/me", response_model=List[VendorSubscriptionResponse])
async def get_my_subscriptions(
    db: AsyncSession = Depends(get_db),
    current_vendor: Vendor = Depends(get_current_vendor)
):
    """
    Fetches the active and past subscriptions for the current vendor.
    """
    query = select(VendorSubscription).options(joinedload(VendorSubscription.plan)).where(
        VendorSubscription.vendor_id == current_vendor.id
    ).order_by(VendorSubscription.end_date.desc())
    
    result = await db.execute(query)
    subscriptions = result.scalars().all()
    return subscriptions

@router.post("/purchase")
async def purchase_plan(
    request: PurchasePlanRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    current_vendor: Vendor = Depends(get_current_vendor)
):
    """
    Creates a Razorpay order to purchase a subscription plan for a vendor.
    """
    # Check if plan exists
    plan_query = select(SubscriptionPlan).where(SubscriptionPlan.id == request.plan_id)
    plan_res = await db.execute(plan_query)
    plan = plan_res.scalar_one_or_none()
    
    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found")

    replace_sub = await _validate_plan_purchase(db, current_vendor.id, plan)

    if plan.price > 0:
        # Create Razorpay Order
        order_amount = int(plan.price * 100) # Amount in paisa
        order_currency = "INR"
        order_receipt = f"receipt_sub_{current_vendor.id}_{plan.id}"
        
        try:
            razorpay_order = rzp_client.order.create(dict(
                amount=order_amount,
                currency=order_currency,
                receipt=order_receipt,
                notes={
                    "vendor_id": current_vendor.id,
                    "plan_id": plan.id
                }
            ))
            return {
                "message": "Payment order created successfully",
                "order_id": razorpay_order["id"],
                "amount": razorpay_order["amount"],
                "currency": razorpay_order["currency"],
                "vendor_id": current_vendor.id,
                "plan_name": plan.name
            }
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
    else:
        # If plan is free (e.g., Commission Plans), directly create subscription
        return await _activate_vendor_subscription(
            db,
            current_vendor,
            plan,
            background_tasks,
            replace_sub=replace_sub,
            is_upgrade=replace_sub is not None,
        )

@router.post("/verify-payment")
async def verify_payment(
    request: VerifyPaymentRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    current_vendor: Vendor = Depends(get_current_vendor)
):
    """
    Verifies the Razorpay payment signature and activates the subscription plan.
    """
    try:
        # Verify Signature
        rzp_client.utility.verify_payment_signature({
            'razorpay_order_id': request.razorpay_order_id,
            'razorpay_payment_id': request.razorpay_payment_id,
            'razorpay_signature': request.razorpay_signature
        })
    except razorpay.errors.SignatureVerificationError:
        raise HTTPException(status_code=400, detail="Invalid payment signature")
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

    existing_sub = await _get_active_subscription(db, current_vendor.id)
    plan_query = select(SubscriptionPlan).where(SubscriptionPlan.id == request.plan_id)
    plan_res = await db.execute(plan_query)
    plan = plan_res.scalar_one_or_none()

    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found")

    if existing_sub:
        _, current_plan = await _get_active_plan(db, current_vendor.id)
        if current_plan and plan.id == current_plan.id:
            return await _subscription_already_active_response(
                db, current_vendor, existing_sub
            )
        replace_sub = await _validate_plan_purchase(db, current_vendor.id, plan)
        return await _activate_vendor_subscription(
            db,
            current_vendor,
            plan,
            background_tasks,
            replace_sub=replace_sub,
            is_upgrade=True,
        )

    return await _activate_vendor_subscription(db, current_vendor, plan, background_tasks)


@router.post("/recover-payment")
async def recover_payment(
    request: RecoverPaymentRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    current_vendor: Vendor = Depends(get_current_vendor),
):
    """
    Recovers a subscription when Razorpay captured payment but the app callback failed.
    """
    existing_sub = await _get_active_subscription(db, current_vendor.id)
    plan_query = select(SubscriptionPlan).where(SubscriptionPlan.id == request.plan_id)
    plan_res = await db.execute(plan_query)
    plan = plan_res.scalar_one_or_none()
    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found")

    try:
        order = rzp_client.order.fetch(request.razorpay_order_id)
    except Exception as exc:
        raise HTTPException(status_code=400, detail=f"Unable to fetch payment order: {exc}")

    notes = order.get("notes") or {}
    if str(notes.get("vendor_id")) != str(current_vendor.id):
        raise HTTPException(status_code=403, detail="Order does not belong to this vendor")
    if int(notes.get("plan_id") or 0) != request.plan_id:
        raise HTTPException(status_code=400, detail="Plan mismatch for this payment order")

    try:
        payments = rzp_client.order.payments(request.razorpay_order_id)
    except Exception as exc:
        raise HTTPException(status_code=400, detail=f"Unable to fetch order payments: {exc}")

    captured_payments = [
        payment
        for payment in payments.get("items", [])
        if payment.get("status") == "captured"
    ]
    if not captured_payments:
        raise HTTPException(
            status_code=400,
            detail="No successful payment found for this order yet. Please wait a minute and try again.",
        )

    if existing_sub:
        _, current_plan = await _get_active_plan(db, current_vendor.id)
        if current_plan and plan.id == current_plan.id:
            return await _subscription_already_active_response(
                db, current_vendor, existing_sub
            )
        replace_sub = await _validate_plan_purchase(db, current_vendor.id, plan)
        return await _activate_vendor_subscription(
            db,
            current_vendor,
            plan,
            background_tasks,
            replace_sub=replace_sub,
            is_upgrade=True,
        )

    return await _activate_vendor_subscription(db, current_vendor, plan, background_tasks)
