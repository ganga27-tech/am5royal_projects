from typing import List, Optional
import uuid
import datetime
from datetime import date, time, timezone, datetime, timedelta
import random
import json

from fastapi import APIRouter, Depends, HTTPException, Query, Request, BackgroundTasks
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text

from app.db.session import get_db
from app.models.orders import Order as OrderModel, OrderItem as OrderItemModel
from app.models.vendor import Vendor, VendorService
from app.models.subscriptions import VendorSubscription, SubscriptionPlan, VendorWallet, WalletTransaction
from app.models.user_location import Customer, Address as AddressModel
from app.models.catalog import Package as PackageModel, ServiceSubcategory as SubcategoryModel
from app.schemas.orders import OrderCreate, CalculationRequest, CalculationResponse
from app.dependencies.auth import get_current_customer, get_current_vendor
from app.core.rate_limit import limiter
from app.services.booking_assignment_service import (
    build_initial_assignment_meta,
    notify_vendor_new_booking,
    notify_customer_vendor_accepted,
    handle_vendor_decline_or_timeout,
    process_pending_booking_timeouts,
)

router = APIRouter()

@router.get("/", response_model=List[dict])
@limiter.limit("30/minute")
async def get_my_orders(
    request: Request,
    db: AsyncSession = Depends(get_db),
    current_customer: Customer = Depends(get_current_customer)
):
    """
    Get order history for the logged-in customer (Matches PDF Page 44).
    """
    query = select(OrderModel).where(OrderModel.customer_id == current_customer.id)
    result = await db.execute(query)
    orders = result.scalars().all()

    return [
        {
            "orderId": o.booking_reference or f"HYD{str(o.id).zfill(5)}",
            "invoice": None,
            "razorPayOrderId": None,
            "orderdate": o.created_at.strftime("%Y-%m-%d") if o.created_at else None,
            "ordertime": o.created_at.strftime("%I:%M %p") if o.created_at else None,
            "serviceDate": o.booking_date.strftime("%Y-%m-%d") if o.booking_date else None,
            "serviceTime": o.booking_time.strftime("%I:%M %p") if o.booking_time else None,
            "status": o.status,
            "customer_name": o.customer_name or current_customer.full_name,
            "email": o.customer_email or current_customer.email,
            "contactNumber": o.customer_phone or current_customer.phone,
            "totalAmount": float(o.total_amount or 0.0),
            "finalAmount": float(o.final_amount or 0.0),
            "service_name": o.service_name,
            "service_category": o.service_category
        }
        for o in orders
    ]

@router.post("/", response_model=dict)
@limiter.limit("5/minute")
async def create_order(
    request: Request,
    order_in: OrderCreate,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    current_customer: Customer = Depends(get_current_customer),
):
    """
    Create a new booking (Matches PDF Page 44).
    """
    # 1. Fetch Address details
    address_res = await db.execute(
        select(AddressModel).where(
            AddressModel.id == order_in.address_id,
            AddressModel.customer_id == current_customer.id
        )
    )
    address = address_res.scalar_one_or_none()
    if not address:
        raise HTTPException(status_code=400, detail="Invalid address_id or address does not belong to customer")

    # Format the full text address
    address_parts = [address.address_line1]
    if address.address_line2:
        address_parts.append(address.address_line2)
    if address.city:
        address_parts.append(address.city)
    if address.state:
        address_parts.append(address.state)
    if address.pincode:
        address_parts.append(address.pincode)
    service_address = ", ".join(address_parts)

    # 2. Get and validate all packages/subcategories to extract all subcategory_ids
    if not order_in.items:
        raise HTTPException(status_code=400, detail="Order items cannot be empty")

    subcategory_ids = set()
    first_item = order_in.items[0]
    package = None
    subcategory = None

    for idx, item in enumerate(order_in.items):
        if item.package_id:
            package_res = await db.execute(select(PackageModel).where(PackageModel.id == item.package_id))
            item_package = package_res.scalar_one_or_none()
            if not item_package:
                raise HTTPException(status_code=400, detail=f"Package not found for ID {item.package_id}")
            subcategory_ids.add(item_package.subcategory_id)
            if idx == 0:
                package = item_package
                subcat_res = await db.execute(select(SubcategoryModel).where(SubcategoryModel.id == package.subcategory_id))
                subcategory = subcat_res.scalar_one_or_none()
        elif item.subcategory_id:
            subcat_res = await db.execute(select(SubcategoryModel).where(SubcategoryModel.id == item.subcategory_id))
            item_subcategory = subcat_res.scalar_one_or_none()
            if not item_subcategory:
                raise HTTPException(status_code=400, detail=f"Subcategory not found for ID {item.subcategory_id}")
            subcategory_ids.add(item_subcategory.id)
            if idx == 0:
                subcategory = item_subcategory
        else:
            raise HTTPException(status_code=400, detail="Either package_id or subcategory_id must be provided for order items")

    # 3. Calculate total price and build order items
    total_amount = 0.0
    order_items = []
    for item in order_in.items:
        item_total = item.quantity * item.unit_price
        total_amount += item_total
        order_items.append(
            OrderItemModel(
                package_id=item.package_id,
                quantity=item.quantity,
                price=item.unit_price
            )
        )

    # 4. Construct scheduled_at components
    booking_date = order_in.scheduled_at.date()
    booking_time = order_in.scheduled_at.time()

    # 5. Fetch and Validate Vendor details (current schema uses vendors table)
    vendor_profile_id = order_in.vendor_profile_id
    vendor_name = "Default Vendor"
    vendor_phone = "9999999999"
    vendor_email = "vendor@example.com"
    resolved_vendor_id = None

    if vendor_profile_id is not None:
        vendor_res = await db.execute(
            select(Vendor).where(Vendor.id == vendor_profile_id)
        )
        vendor_obj = vendor_res.scalar_one_or_none()
        if not vendor_obj:
            raise HTTPException(
                status_code=400,
                detail=f"Vendor not found for ID {vendor_profile_id}",
            )

        resolved_vendor_id = vendor_obj.id
        vendor_name = vendor_obj.business_name or "Vendor"
        vendor_phone = vendor_obj.mobile or vendor_phone
        vendor_email = vendor_obj.email or vendor_email

        services_res = await db.execute(
            select(VendorService.sub_category_id).where(
                VendorService.vendor_id == vendor_obj.id,
                VendorService.is_active == True,
            )
        )
        provided_subcats = {row[0] for row in services_res.fetchall() if row[0]}
        missing_subcats = subcategory_ids - provided_subcats
        if missing_subcats and provided_subcats:
            raise HTTPException(
                status_code=400,
                detail=(
                    "Selected vendor does not provide the requested services "
                    f"(missing subcategory IDs: {list(missing_subcats)})"
                ),
            )
    else:
        vendor_res = await db.execute(select(Vendor).where(Vendor.id == 1))
        vendor_obj = vendor_res.scalar_one_or_none()
        if vendor_obj:
            resolved_vendor_id = vendor_obj.id
            vendor_profile_id = vendor_obj.id
            vendor_name = vendor_obj.business_name or vendor_name
            vendor_phone = vendor_obj.mobile or vendor_phone
            vendor_email = vendor_obj.email or vendor_email
        else:
            vendor_profile_id = 1

    # 6. Create Order
    new_order = OrderModel(
        customer_id=current_customer.id,
        vendor_id=resolved_vendor_id,
        vendor_profile_id=vendor_profile_id,
        booking_reference=f"HYD{uuid.uuid4().hex[:6].upper()}",
        status="PENDING",
        service_id=subcategory.id if subcategory else None,
        service_subcategory_id=subcategory.id if subcategory else None,
        service_category_id=subcategory.category_id if subcategory else None,
        booking_date=booking_date,
        booking_time=booking_time,
        service_address=service_address,
        latitude=address.latitude,
        longitude=address.longitude,
        total_amount=total_amount,
        final_amount=total_amount,
        customer_name=current_customer.full_name,
        customer_phone=current_customer.phone,
        customer_email=current_customer.email,
        vendor_name=vendor_name,
        vendor_phone=vendor_phone,
        vendor_email=vendor_email,
        service_name=package.name if package else (subcategory.name if subcategory else "General Service"),
        duration_minutes=package.duration_minutes if package else 60,
        special_instructions=order_in.special_instructions,
        vendor_notes=build_initial_assignment_meta(order_in.catalog_service_id),
    )

    db.add(new_order)
    await db.flush() # Get generated order ID

    # Associate and add items
    for item in order_items:
        item.order_id = new_order.id
        db.add(item)

    await db.commit()
    await db.refresh(new_order)

    if vendor_obj and resolved_vendor_id:
        await notify_vendor_new_booking(vendor_obj, new_order, background_tasks)

    return {"message": "Order created successfully", "orderId": new_order.booking_reference, "status": "PENDING"}

class RejectBookingRequest(BaseModel):
    reason: Optional[str] = None


@router.put("/{order_id}/accept")
@limiter.limit("10/minute")
async def accept_booking(
    request: Request,
    order_id: str,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    current_vendor: Vendor = Depends(get_current_vendor),
):
    """Vendor accepts a pending booking."""
    result = await db.execute(
        select(OrderModel).where(OrderModel.booking_reference == order_id)
    )
    order = result.scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    if order.vendor_id != current_vendor.id:
        raise HTTPException(status_code=403, detail="This booking is not assigned to you")
    if order.status not in ("PENDING", "new"):
        raise HTTPException(
            status_code=400,
            detail=f"Cannot accept booking with status {order.status}",
        )

    order.status = "ACCEPTED"
    order.accepted_at = datetime.datetime.utcnow()
    order.confirmed_at = datetime.datetime.utcnow()
    order.vendor_name = current_vendor.business_name or order.vendor_name
    order.vendor_phone = current_vendor.mobile or order.vendor_phone
    await db.commit()
    await db.refresh(order)

    await notify_customer_vendor_accepted(
        db,
        order,
        current_vendor,
        background_tasks=background_tasks,
    )

    return {
        "message": "Booking accepted successfully",
        "orderId": order.booking_reference,
        "status": order.status,
    }


@router.put("/{order_id}/reject")
@limiter.limit("10/minute")
async def reject_booking(
    request: Request,
    order_id: str,
    body: RejectBookingRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    current_vendor: Vendor = Depends(get_current_vendor),
):
    """
    Vendor rejects a pending booking. System reassigns to the next nearest
    eligible vendor with price <= booked amount, or marks unassigned.
    """
    result = await db.execute(
        select(OrderModel).where(OrderModel.booking_reference == order_id)
    )
    order = result.scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    if order.vendor_id != current_vendor.id:
        raise HTTPException(status_code=403, detail="This booking is not assigned to you")
    if order.status not in ("PENDING", "new"):
        raise HTTPException(
            status_code=400,
            detail=f"Cannot reject booking with status {order.status}",
        )

    outcome = await handle_vendor_decline_or_timeout(
        db,
        order,
        declined_vendor_id=current_vendor.id,
        reason=body.reason,
        background_tasks=background_tasks,
    )
    return outcome


@router.post("/process-pending-timeouts")
@limiter.limit("5/minute")
async def run_pending_booking_timeouts(
    request: Request,
    background_tasks: BackgroundTasks,
):
    """
    Cron/manual endpoint: reassign bookings vendors did not accept within 15 minutes.
    """
    processed = await process_pending_booking_timeouts(background_tasks)
    return {"processed": processed, "message": f"Processed {processed} timed-out bookings"}

@router.put("/{order_id}/cancel")
@limiter.limit("3/minute")
async def cancel_order(
    request: Request,
    order_id: str,
    reason: str = Query(..., description="Reason for cancellation"),
    db: AsyncSession = Depends(get_db),
    current_customer: Customer = Depends(get_current_customer)
):
    """
    Cancel an existing order (Matches PDF Page 64).
    """
    query = select(OrderModel).where(
        OrderModel.booking_reference == order_id,
        OrderModel.customer_id == current_customer.id
    )
    result = await db.execute(query)
    order = result.scalar_one_or_none()

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    order.status = "CANCELLED"
    order.cancellation_reason = reason
    order.cancelled_at = datetime.datetime.utcnow()
    order.cancelled_by = "customer"

    await db.commit()
    return {"message": "Your Order cancelled successfully"}

@router.put("/{order_id}/reschedule")
@limiter.limit("3/minute")
async def reschedule_order(
    request: Request,
    order_id: str,
    new_date: date = Query(...),
    new_time: time = Query(...),
    db: AsyncSession = Depends(get_db),
    current_customer: Customer = Depends(get_current_customer)
):
    """
    Reschedule an existing order.
    """
    query = select(OrderModel).where(
        OrderModel.booking_reference == order_id,
        OrderModel.customer_id == current_customer.id
    )
    result = await db.execute(query)
    order = result.scalar_one_or_none()

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    order.booking_date = new_date
    order.booking_time = new_time
    order.reschedule_count += 1

    await db.commit()
    return {"message": "Order rescheduled successfully"}

@router.post("/order/calculation", response_model=CalculationResponse)
@limiter.limit("15/minute")
async def calculate_order_amount(
    request: Request,
    calc_in: CalculationRequest,
    db: AsyncSession = Depends(get_db),
    current_customer: Customer = Depends(get_current_customer)
):
    """
    Calculate order pricing details, taxes, discounts, and royalty metrics (Matches external calculations endpoint).
    """
    # Calculate sum of package amounts
    package_amount = 0.0
    for pkg in calc_in.packages:
        qty = int(pkg.quantity)
        amt = float(pkg.packageAmount)
        package_amount += amt * qty

    # Fixed pricing constants based on the analyzed schema
    platform_charge = 0.0
    platform_charge_paid = 15.0
    visiting_charge = 0.0
    visiting_charge_paid = 0.0

    # Calculate tax components
    gst_on_charges = round(platform_charge_paid * 0.18, 2)
    # package amount is tax inclusive (18%)
    included_gst = round(package_amount - (package_amount / 1.18), 2)
    # GST in output represents platform charge + its GST
    gst = platform_charge_paid + gst_on_charges

    # Calculate discounts
    royal_discount = round(0.05 * package_amount + 0.06 * platform_charge_paid, 2)
    maximum_discount = round(0.035 * package_amount - 0.009 * platform_charge_paid, 2)

    # Calculate Revenue
    royal_revenue = round(0.125 * package_amount - 0.017 * platform_charge_paid, 2)

    # Calculate total payable amount (rounded to nearest integer)
    total_amount = round(package_amount - royal_discount + gst)

    # Resolve customer ID from authenticated token
    visit_id_prefix = f"HYDCX{str(current_customer.id).zfill(5)}"
    referral_count = 0

    # Generate a deterministic or randomized 4-digit code (e.g. 0313)
    rand_seq = random.randint(100, 9999)
    visit_id = f"{visit_id_prefix}OCV{rand_seq:04d}"

    return CalculationResponse(
        packageAmount=package_amount,
        platformCharge=platform_charge,
        platformChargePaid=platform_charge_paid,
        visitingCharge=visiting_charge,
        visitingChargePaid=visiting_charge_paid,
        GST=gst,
        gstOnCharges=gst_on_charges,
        includedGST=included_gst,
        totalAmount=total_amount,
        memberSaving=0,
        maximumDiscount=maximum_discount,
        influencerDiscount=0.0,
        Am5RoyalDiscount=royal_discount,
        Am5ROYALRevenue=royal_revenue,
        referralCount=referral_count,
        visitId=visit_id
    )

def _parse_ids(input_str: Optional[str]) -> List[int]:
    if not input_str:
        return []
    input_str = input_str.strip()
    if not input_str:
        return []
    if input_str.startswith('[') and input_str.endswith(']'):
        try:
            val = json.loads(input_str)
            if isinstance(val, list):
                return [int(x) for x in val]
            return [int(val)]
        except Exception:
            pass
    # Comma-separated fallback
    parts = input_str.split(',')
    res = []
    for p in parts:
        p = p.strip()
        if p.isdigit():
            res.append(int(p))
    return res

@router.get("/availableServiceProviderSlots", response_model=List[str])
@limiter.limit("30/minute")
async def get_available_service_provider_slots(
    request: Request,
    professionId: Optional[int] = Query(None),
    serviceIds: Optional[str] = Query(None),
    packageIds: Optional[str] = Query(None),
    addressId: Optional[str] = Query(None),
    serviceDate: Optional[str] = Query(None),
    customerId: Optional[str] = Query(None),
    db: AsyncSession = Depends(get_db)
):
    """
    Get available service provider slots for a given date, profession, services, and address.
    """
    # Parse lists of IDs
    service_id_list = _parse_ids(serviceIds)
    package_id_list = _parse_ids(packageIds)

    # 1. Parse serviceDate (default to today in IST timezone)
    ist = timezone(timedelta(hours=5, minutes=30))
    now_ist = datetime.now(timezone.utc).astimezone(ist)

    target_date = now_ist.date()
    if serviceDate:
        try:
            target_date = datetime.strptime(serviceDate.strip(), "%Y-%m-%d").date()
        except Exception:
            pass

    # 2. Retrieve address details for location filtering
    city = None
    pincode = None
    if addressId:
        try:
            addr_id_str = "".join(filter(str.isdigit, str(addressId)))
            if addr_id_str:
                addr_id = int(addr_id_str)
                addr_res = await db.execute(
                    select(AddressModel).where(AddressModel.id == addr_id)
                )
                address = addr_res.scalar_one_or_none()
                if address:
                    city = address.city
                    pincode = address.pincode
        except Exception:
            pass

    # Determine weekday abbreviation (e.g. MON, TUE, SAT)
    weekday_abbr = target_date.strftime('%a').upper()

    # 3. Query eligible vendors offering the requested subcategories/categories
    where_clauses = [
        "v.status = 'APPROVED'",
        "vs.is_active = True"
    ]
    query_params = {}

    if service_id_list:
        where_clauses.append("vs.subcategory_id IN :service_ids")
        query_params["service_ids"] = tuple(service_id_list)
    elif professionId:
        where_clauses.append("sub.category_id = :profession_id")
        query_params["profession_id"] = int(professionId)

    # Location joining & filtering strings
    location_joined = ""
    location_filter = ""
    if city:
        location_joined = "LEFT JOIN service_locations sl ON sl.vendor_profile_id = vp.id AND sl.is_active = True"
        location_filter = "AND (LOWER(sl.city) = LOWER(:city) OR sl.postal_code = :pincode OR sl.pincode = :pincode)"
        query_params["city"] = city
        query_params["pincode"] = pincode or ""

    query_str = f"""
        SELECT DISTINCT vs.vendor_profile_id, v.id as vendor_id, vs.schedule_from_time, vs.schedule_to_time, vs.available_days, vs.min_advance_hours
        FROM vendor_services vs
        JOIN service_subcategories sub ON sub.id = vs.subcategory_id
        JOIN vendor_profiles vp ON vp.id = vs.vendor_profile_id
        JOIN vendors v ON v.user_id = vp.user_id
        {location_joined}
        WHERE {" AND ".join(where_clauses)}
        {location_filter}
    """

    try:
        res = await db.execute(text(query_str), query_params)
        eligible_vendors = res.fetchall()
    except Exception:
        eligible_vendors = []

    # Soft fallback: if no vendors found under location filter, search without location constraint
    if not eligible_vendors and city:
        query_str_fallback = f"""
            SELECT DISTINCT vs.vendor_profile_id, v.id as vendor_id, vs.schedule_from_time, vs.schedule_to_time, vs.available_days, vs.min_advance_hours
            FROM vendor_services vs
            JOIN service_subcategories sub ON sub.id = vs.subcategory_id
            JOIN vendor_profiles vp ON vp.id = vs.vendor_profile_id
            JOIN vendors v ON v.user_id = vp.user_id
            WHERE {" AND ".join(where_clauses)}
        """
        fallback_params = {k: v for k, v in query_params.items() if k not in ["city", "pincode"]}
        try:
            res = await db.execute(text(query_str_fallback), fallback_params)
            eligible_vendors = res.fetchall()
        except Exception:
            pass

    available_slots = set()
    default_slots = ["08:30-11:30", "11:30-14:30", "14:30-17:30"]

    # Gather available slots across all matched vendors
    for vendor in eligible_vendors:
        # Check day-of-week availability
        available_days = vendor.available_days
        if available_days:
            days_list = [d.strip().upper() for d in available_days.split(',')]
            if weekday_abbr not in days_list:
                continue # Skip vendor if they don't work on this day

        # Check vendor schedule hours (fallback to 08:30-17:30 if not specified)
        from_time_str = vendor.schedule_from_time or "08:30"
        to_time_str = vendor.schedule_to_time or "17:30"

        try:
            vendor_start = datetime.strptime(from_time_str.strip(), "%H:%M").time()
            vendor_end = datetime.strptime(to_time_str.strip(), "%H:%M").time()
        except Exception:
            vendor_start = datetime.strptime("08:30", "%H:%M").time()
            vendor_end = datetime.strptime("17:30", "%H:%M").time()

        # Check custom availability records first
        try:
            avail_res = await db.execute(
                text("""
                    SELECT time_slot FROM recurring_availability 
                    WHERE vendor_id = :vendor_id AND day_of_week = :day_of_week AND is_active = True
                    UNION
                    SELECT start_time || '-' || end_time as time_slot FROM vendor_availability
                    WHERE vendor_id = :vendor_id AND day_of_week = :day_of_week
                """),
                {"vendor_id": vendor.vendor_id, "day_of_week": weekday_abbr}
            )
            custom_slots = [r[0] for r in avail_res.fetchall()]
        except Exception:
            custom_slots = []

        vendor_slots = []
        if custom_slots:
            vendor_slots = custom_slots
        else:
            # Match default slots with vendor's daily work window
            for slot in default_slots:
                parts = slot.split('-')
                if len(parts) == 2:
                    try:
                        slot_start = datetime.strptime(parts[0].strip(), "%H:%M").time()
                        slot_end = datetime.strptime(parts[1].strip(), "%H:%M").time()
                        if slot_start >= vendor_start and slot_end <= vendor_end:
                            vendor_slots.append(slot)
                    except Exception:
                        pass
            if not vendor_slots:
                vendor_slots = default_slots

        # Filter out booked/blocked slots
        for slot in vendor_slots:
            try:
                # Check booked/blocked counts
                booking_res = await db.execute(
                    text("""
                        SELECT booked_count, held_count, total_capacity, status 
                        FROM booking_vendor_availability 
                        WHERE vendor_id = :vendor_id AND date = :date AND time_slot = :slot
                    """),
                    {"vendor_id": vendor.vendor_id, "date": target_date, "slot": slot}
                )
                booking_info = booking_res.fetchone()
                if booking_info:
                    booked, held, capacity, status = booking_info
                    if status == 'BLOCKED' or (booked + held) >= capacity:
                        continue # No capacity left

                # Check slot holds
                hold_res = await db.execute(
                    text("""
                        SELECT COUNT(*) FROM slot_hold 
                        WHERE vendor_id = :vendor_id AND date = :date AND time_slot = :slot 
                          AND status = 'HELD' AND expires_at > :now
                    """),
                    {"vendor_id": vendor.vendor_id, "date": target_date, "slot": slot, "now": datetime.now(timezone.utc)}
                )
                active_holds = hold_res.scalar()
                if active_holds > 0:
                    total_cap = booking_info[2] if booking_info else 1
                    booked_cnt = booking_info[0] if booking_info else 0
                    if (booked_cnt + active_holds) >= total_cap:
                        continue

                available_slots.add(slot)
            except Exception:
                available_slots.add(slot)

    # 4. Final filter of slots (e.g. filter out past slots if date is today)
    final_slots = list(available_slots if (available_slots or eligible_vendors) else default_slots)

    if target_date == now_ist.date():
        filtered_slots = []
        for slot in final_slots:
            parts = slot.split('-')
            if len(parts) == 2:
                try:
                    slot_start_time = datetime.strptime(parts[0].strip(), "%H:%M").time()
                    slot_dt = datetime.combine(target_date, slot_start_time).replace(tzinfo=ist)

                    # Buffer: min_advance_hours (or fallback to 2 hours)
                    min_buffer_hours = 2.0
                    if slot_dt > now_ist + timedelta(hours=min_buffer_hours):
                        filtered_slots.append(slot)
                except Exception:
                    filtered_slots.append(slot)
            else:
                filtered_slots.append(slot)
        final_slots = filtered_slots

    # Sort slots chronologically
    try:
        final_slots = sorted(list(final_slots), key=lambda s: s.split('-')[0])
    except Exception:
        pass

    return final_slots
from pydantic import BaseModel
from typing import Optional
from app.models.subscriptions import VendorWallet, WalletTransaction, VendorSubscription, SubscriptionPlan
from app.dependencies.auth import get_current_vendor

class GenerateOtpRequest(BaseModel):
    order_id: str

class OtpResponse(BaseModel):
    start_otp: str
    end_otp: str

class StartServiceRequest(BaseModel):
    order_id: str
    start_otp: str

class CompleteServiceRequest(BaseModel):
    order_id: str
    end_otp: str

def generate_random_otp() -> str:
    return str(random.randint(100000, 999999))

@router.post("/generate-otps", response_model=OtpResponse)
async def generate_otps(
    request: GenerateOtpRequest,
    db: AsyncSession = Depends(get_db),
    current_customer: Customer = Depends(get_current_customer)
):
    # Only customer can generate OTPs for their order
    query = select(OrderModel).where(
        OrderModel.booking_reference == request.order_id,
        OrderModel.customer_id == current_customer.id
    )
    res = await db.execute(query)
    order = res.scalar_one_or_none()
    
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
        
    if not order.start_otp or not order.end_otp:
        order.start_otp = generate_random_otp()
        order.end_otp = generate_random_otp()
        await db.commit()
        
    return OtpResponse(start_otp=order.start_otp, end_otp=order.end_otp)
@router.post("/start")
async def start_service(
    request: StartServiceRequest,
    db: AsyncSession = Depends(get_db),
    current_vendor: Vendor = Depends(get_current_vendor)
):
    query = select(OrderModel).where(OrderModel.booking_reference == request.order_id)
    res = await db.execute(query)
    order = res.scalar_one_or_none()
    
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
        
    # In a real app we'd also check order.vendor_profile_id matches current_vendor.profile.id
    
    if order.status != "ACCEPTED" and order.status != "PENDING": # Assuming PENDING or ACCEPTED
        raise HTTPException(status_code=400, detail=f"Cannot start service from status {order.status}")
        
    if order.start_otp != request.start_otp:
        raise HTTPException(status_code=400, detail="Invalid Start OTP")
        
    order.status = "IN_PROGRESS"
    order.started_at = datetime.now(timezone.utc)
    await db.commit()
    
    return {"message": "Service started successfully"}

@router.post("/complete")
async def complete_service(
    request: CompleteServiceRequest,
    db: AsyncSession = Depends(get_db),
    current_vendor: Vendor = Depends(get_current_vendor)
):
    query = select(OrderModel).where(OrderModel.booking_reference == request.order_id)
    res = await db.execute(query)
    order = res.scalar_one_or_none()
    
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
        
    if order.status != "IN_PROGRESS":
        raise HTTPException(status_code=400, detail=f"Cannot complete service from status {order.status}")
        
    if order.end_otp != request.end_otp:
        raise HTTPException(status_code=400, detail="Invalid End OTP")
        
    # Wallet deduction logic
    # Find vendor's active subscription
    sub_query = select(VendorSubscription, SubscriptionPlan).join(
        SubscriptionPlan, VendorSubscription.subscription_plan_id == SubscriptionPlan.id
    ).where(
        VendorSubscription.vendor_id == current_vendor.id,
        VendorSubscription.status == "active"
    )
    sub_res = await db.execute(sub_query)
    sub_record = sub_res.first()
    
    if not sub_record:
        raise HTTPException(status_code=400, detail="No active subscription found for vendor")
        
    vendor_sub, plan = sub_record
    
    # Calculate commission
    commission_amount = 0.0
    if plan.plan_type == 'commission' and plan.commission_percentage:
        commission_amount = float(order.total_amount or 0) * (float(plan.commission_percentage) / 100.0)
    elif plan.plan_type == 'wallet' and plan.per_lead_charge:
        commission_amount = float(plan.per_lead_charge)
        
    if commission_amount > 0:
        # Get wallet
        wallet_query = select(VendorWallet).where(VendorWallet.vendor_id == current_vendor.id)
        w_res = await db.execute(wallet_query)
        wallet = w_res.scalar_one_or_none()
        
        if not wallet:
            raise HTTPException(status_code=400, detail="Vendor wallet not found")
            
        if float(wallet.balance) < commission_amount:
            raise HTTPException(status_code=400, detail="Insufficient wallet balance to complete service. Please top-up.")
            
        # Deduct
        wallet.balance = float(wallet.balance) - commission_amount
        tx = WalletTransaction(
            wallet_id=wallet.id,
            transaction_type='debit',
            amount=-commission_amount,
            description=f"Commission deducted for order {order.booking_reference}"
        )
        db.add(tx)
        
    order.status = "COMPLETED"
    order.completed_at = datetime.now(timezone.utc)
    await db.commit()
    
    return {
        "message": "Service completed successfully",
        "commission_deducted": commission_amount
    }

class VendorOrderResponse(BaseModel):
    id: int
    booking_reference: str
    customer_name: Optional[str] = None
    customer_phone: Optional[str] = None
    service_address: Optional[str] = None
    service_name: Optional[str] = None
    booking_date: Optional[date] = None
    booking_time: Optional[time] = None
    status: str
    total_amount: Optional[float] = None
    start_otp: Optional[str] = None
    end_otp: Optional[str] = None

    class Config:
        from_attributes = True

@router.get("/vendor/me", response_model=List[VendorOrderResponse])
async def get_vendor_orders(
    status_filter: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
    current_vendor: Vendor = Depends(get_current_vendor)
):
    query_str = """
        SELECT 
            b.id,
            'HYD' || LPAD(b.id::text, 5, '0') as booking_reference,
            c.full_name as customer_name,
            c.phone as customer_phone,
            b.booking_address as service_address,
            COALESCE(sub.name, 'General Service') as service_name,
            DATE(b.scheduled_date) as booking_date,
            b.scheduled_date::time as booking_time,
            b.booking_status as status,
            b.total_amount,
            b.start_otp,
            b.end_otp
        FROM bookings b
        LEFT JOIN customers c ON b.customer_id = c.id
        LEFT JOIN vendor_services vs ON b.vendor_service_id = vs.id
        LEFT JOIN service_subcategories sub ON vs.sub_category_id = sub.id
        WHERE b.vendor_id = :vendor_id
    """
    
    where_clauses = []
    if status_filter == "upcoming":
        where_clauses.append("b.booking_status IN ('new', 'ACCEPTED', 'PENDING')")
    elif status_filter == "ongoing":
        where_clauses.append("b.booking_status = 'IN_PROGRESS'")
    elif status_filter == "completed":
        where_clauses.append("b.booking_status = 'COMPLETED'")
        
    if where_clauses:
        query_str += " AND " + " AND ".join(where_clauses)
        
    query_str += " ORDER BY b.created_at DESC"
    
    res = await db.execute(text(query_str), {"vendor_id": current_vendor.id})
    orders = res.fetchall()
    
    result = []
    for o in orders:
        result.append({
            "id": o.id,
            "booking_reference": o.booking_reference,
            "customer_name": o.customer_name,
            "customer_phone": o.customer_phone,
            "service_address": o.service_address,
            "service_name": o.service_name,
            "booking_date": o.booking_date,
            "booking_time": o.booking_time,
            "status": o.status or 'pending',
            "total_amount": float(o.total_amount) if o.total_amount else 0.0,
            "start_otp": o.start_otp,
            "end_otp": o.end_otp
        })
        
    return result
