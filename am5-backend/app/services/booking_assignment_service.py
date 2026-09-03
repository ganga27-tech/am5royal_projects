"""
Booking vendor assignment: push notifications, accept/reject, and reassignment.
"""
from __future__ import annotations

import json
import logging
from datetime import datetime, timedelta
from typing import Any, Dict, List, Optional, Tuple

from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.geo import haversine_km, SEARCH_RADII_KM
from app.models.orders import Order
from app.models.vendor import Vendor, VendorService
from app.models.subscriptions import VendorSubscription, SubscriptionPlan
from app.models.orders import Order as OrderModel
from app.models.user_location import Customer
from app.services.notification_service import send_user_push_notification
from app.services.otp_service import otp_service

logger = logging.getLogger(__name__)

VENDOR_ASSIGNMENT_META_KEY = "vendor_assignment"
ACCEPT_TIMEOUT_MINUTES = 15


def _parse_assignment_meta(vendor_notes: Optional[str]) -> Dict[str, Any]:
    if not vendor_notes:
        return {"declined_vendor_ids": [], "assigned_at": None, "catalog_service_id": None}
    try:
        data = json.loads(vendor_notes)
        if isinstance(data, dict):
            return {
                "declined_vendor_ids": list(data.get("declined_vendor_ids") or []),
                "assigned_at": data.get("assigned_at"),
                "catalog_service_id": data.get("catalog_service_id"),
            }
    except (json.JSONDecodeError, TypeError):
        pass
    return {"declined_vendor_ids": [], "assigned_at": None, "catalog_service_id": None}


def _serialize_assignment_meta(meta: Dict[str, Any]) -> str:
    return json.dumps(
        {
            "declined_vendor_ids": meta.get("declined_vendor_ids") or [],
            "assigned_at": meta.get("assigned_at"),
            "catalog_service_id": meta.get("catalog_service_id"),
        }
    )


def build_initial_assignment_meta(
    catalog_service_id: Optional[int] = None,
) -> str:
    return _serialize_assignment_meta(
        {
            "declined_vendor_ids": [],
            "assigned_at": datetime.utcnow().isoformat(),
            "catalog_service_id": catalog_service_id,
        }
    )


async def notify_vendor_new_booking(
    vendor: Vendor,
    order: Order,
    background_tasks=None,
) -> None:
    customer_name = order.customer_name or "Customer"
    booking_id = order.booking_reference or ""

    if vendor.mobile:
        if background_tasks is not None:
            background_tasks.add_task(
                otp_service.send_vendor_new_booking_sms,
                vendor.mobile,
                customer_name,
                booking_id,
            )
        else:
            await otp_service.send_vendor_new_booking_sms(
                vendor.mobile,
                customer_name,
                booking_id,
            )

    if not vendor.user_id:
        logger.warning("Vendor %s has no user_id; skip booking push", vendor.id)
        return

    title = "New Booking Request"
    body = (
        f"You received a new booking for {order.service_name or 'a service'} "
        f"on {order.booking_date}. Please accept or reject."
    )
    data = {
        "type": "new_booking",
        "order_id": booking_id,
    }

    if background_tasks is not None:
        background_tasks.add_task(
            send_user_push_notification,
            vendor.user_id,
            title,
            body,
            data,
        )
    else:
        await send_user_push_notification(vendor.user_id, title, body, data)


async def notify_customer_vendor_accepted(
    db: AsyncSession,
    order: Order,
    vendor: Vendor,
    background_tasks=None,
) -> None:
    """SMS + push when vendor accepts a booking."""
    customer_phone = order.customer_phone
    if not customer_phone and order.customer_id:
        customer_res = await db.execute(
            select(Customer).where(Customer.id == order.customer_id)
        )
        customer = customer_res.scalar_one_or_none()
        if customer:
            customer_phone = customer.phone

    vendor_name = (
        order.vendor_name
        or vendor.business_name
        or "Vendor"
    )
    vendor_contact = order.vendor_phone or vendor.mobile or ""
    booking_id = order.booking_reference or str(order.id)
    service_name = order.service_name or "Service"

    if customer_phone:
        if background_tasks is not None:
            background_tasks.add_task(
                otp_service.send_customer_vendor_assigned_sms,
                customer_phone,
                vendor_name,
                booking_id,
                vendor_contact,
                service_name,
            )
        else:
            await otp_service.send_customer_vendor_assigned_sms(
                customer_phone,
                vendor_name,
                booking_id,
                vendor_contact,
                service_name,
            )
    else:
        logger.warning(
            "No customer phone for order %s; skip vendor-assigned SMS",
            booking_id,
        )

    if not order.customer_id:
        return
    customer_res = await db.execute(
        select(Customer).where(Customer.id == order.customer_id)
    )
    customer = customer_res.scalar_one_or_none()
    if not customer or not customer.user_id:
        return

    title = "Vendor Assigned"
    body = (
        f"{vendor_name} has accepted your booking for {service_name}. "
        "They will contact you to confirm the schedule."
    )
    data = {
        "type": "booking_accepted",
        "order_id": booking_id,
    }
    if background_tasks is not None:
        background_tasks.add_task(
            send_user_push_notification,
            customer.user_id,
            title,
            body,
            data,
        )
    else:
        await send_user_push_notification(customer.user_id, title, body, data)


async def notify_customer_reassignment(
    db: AsyncSession,
    order: Order,
    vendor_name: str,
    background_tasks=None,
) -> None:
    if not order.customer_id:
        return
    customer_res = await db.execute(
        select(Customer).where(Customer.id == order.customer_id)
    )
    customer = customer_res.scalar_one_or_none()
    if not customer or not customer.user_id:
        return

    title = "Vendor Updated"
    body = f"Your booking was assigned to {vendor_name}. They will confirm shortly."
    data = {
        "type": "booking_reassigned",
        "order_id": order.booking_reference or "",
    }
    if background_tasks is not None:
        background_tasks.add_task(
            send_user_push_notification,
            customer.user_id,
            title,
            body,
            data,
        )
    else:
        await send_user_push_notification(customer.user_id, title, body, data)


async def notify_customer_no_vendor(
    db: AsyncSession,
    order: Order,
    background_tasks=None,
) -> None:
    if not order.customer_id:
        return
    customer_res = await db.execute(
        select(Customer).where(Customer.id == order.customer_id)
    )
    customer = customer_res.scalar_one_or_none()
    if not customer or not customer.user_id:
        return

    title = "Booking Update"
    body = (
        "We could not find an available vendor for your booking right now. "
        "Our team will contact you shortly."
    )
    data = {
        "type": "booking_unassigned",
        "order_id": order.booking_reference or "",
    }
    if background_tasks is not None:
        background_tasks.add_task(
            send_user_push_notification,
            customer.user_id,
            title,
            body,
            data,
        )
    else:
        await send_user_push_notification(customer.user_id, title, body, data)


async def find_next_vendor_for_order(
    db: AsyncSession,
    order: Order,
    excluded_vendor_ids: List[int],
) -> Optional[Tuple[Vendor, VendorService]]:
    """
    Find the nearest eligible vendor (active subscription, matching service,
    price <= booked amount) excluding previously declined vendors.
    """
    meta = _parse_assignment_meta(order.vendor_notes)
    max_price = float(order.final_amount or order.total_amount or 0)
    subcategory_id = order.service_subcategory_id
    category_id = order.service_category_id
    catalog_service_id = meta.get("catalog_service_id")

    if not subcategory_id and not catalog_service_id:
        return None

    excluded = set(excluded_vendor_ids or [])

    vs_query = (
        select(VendorService, Vendor)
        .join(Vendor, Vendor.id == VendorService.vendor_id)
        .join(VendorSubscription, VendorSubscription.vendor_id == Vendor.id)
        .join(SubscriptionPlan, VendorSubscription.subscription_plan_id == SubscriptionPlan.id)
        .where(VendorService.is_active == True)
        .where(Vendor.status == "active")
        .where(VendorSubscription.status == "active")
        .where(VendorSubscription.end_date >= datetime.utcnow())
    )

    if subcategory_id:
        vs_query = vs_query.where(VendorService.sub_category_id == subcategory_id)
    if category_id:
        vs_query = vs_query.where(VendorService.main_category_id == category_id)
    if catalog_service_id:
        vs_query = vs_query.where(VendorService.service_id == catalog_service_id)
    if excluded:
        vs_query = vs_query.where(Vendor.id.notin_(list(excluded)))

    # Price filter: vendor service price must be <= customer's booked price
    if max_price > 0:
        effective_price = func.coalesce(
            VendorService.discounted_price, VendorService.price
        )
        vs_query = vs_query.where(effective_price <= max_price)

    result = await db.execute(vs_query)
    rows = result.all()
    if not rows:
        return None

    customer_lat = float(order.latitude) if order.latitude is not None else None
    customer_lon = float(order.longitude) if order.longitude is not None else None

    candidates: List[Tuple[Vendor, VendorService, float]] = []
    for vs, vendor in rows:
        distance_km = 9999.0
        if (
            customer_lat is not None
            and customer_lon is not None
            and vendor.latitude is not None
            and vendor.longitude is not None
        ):
            distance_km = haversine_km(
                customer_lat,
                customer_lon,
                float(vendor.latitude),
                float(vendor.longitude),
            )
            vendor_radius = vendor.service_radius_km or 10
            if distance_km > max(SEARCH_RADII_KM):
                continue
            if distance_km > vendor_radius:
                continue
        candidates.append((vendor, vs, distance_km))

    if not candidates and rows:
        # No coordinates — return first eligible vendor
        vendor, vs = rows[0][1], rows[0][0]
        return vendor, vs

    if not candidates:
        return None

    candidates.sort(key=lambda item: (item[2], float(item[0].avg_rating or 0) * -1))
    vendor, vs, _ = candidates[0]
    return vendor, vs


async def assign_order_to_vendor(
    db: AsyncSession,
    order: Order,
    vendor: Vendor,
    background_tasks=None,
    notify_customer: bool = False,
) -> None:
    meta = _parse_assignment_meta(order.vendor_notes)
    meta["assigned_at"] = datetime.utcnow().isoformat()

    order.vendor_id = vendor.id
    order.vendor_profile_id = vendor.id
    order.vendor_name = vendor.business_name or "Vendor"
    order.vendor_phone = vendor.mobile
    order.vendor_email = vendor.email
    order.status = "PENDING"
    order.accepted_at = None
    order.rejected_at = None
    order.rejection_reason = None
    order.vendor_notes = _serialize_assignment_meta(meta)

    db.add(order)
    await db.flush()

    await notify_vendor_new_booking(vendor, order, background_tasks)
    if notify_customer:
        await notify_customer_reassignment(db, order, vendor.business_name or "Vendor", background_tasks)


async def handle_vendor_decline_or_timeout(
    db: AsyncSession,
    order: Order,
    declined_vendor_id: int,
    reason: Optional[str] = None,
    background_tasks=None,
    is_timeout: bool = False,
) -> Dict[str, Any]:
    if order.status not in ("PENDING", "new"):
        return {"reassigned": False, "message": "Order is not awaiting vendor acceptance"}

    meta = _parse_assignment_meta(order.vendor_notes)
    declined = list(meta.get("declined_vendor_ids") or [])
    if declined_vendor_id and declined_vendor_id not in declined:
        declined.append(declined_vendor_id)
    meta["declined_vendor_ids"] = declined
    order.vendor_notes = _serialize_assignment_meta(meta)

    if is_timeout:
        order.rejection_reason = reason or "Vendor did not accept within time limit"
    else:
        order.rejection_reason = reason or "Vendor rejected the booking"
    order.rejected_at = datetime.utcnow()

    next_match = await find_next_vendor_for_order(db, order, declined)
    if next_match:
        vendor, _ = next_match
        await assign_order_to_vendor(
            db,
            order,
            vendor,
            background_tasks=background_tasks,
            notify_customer=True,
        )
        await db.commit()
        return {
            "reassigned": True,
            "new_vendor_id": vendor.id,
            "new_vendor_name": vendor.business_name,
            "message": "Booking reassigned to another nearby vendor",
        }

    order.status = "UNASSIGNED"
    db.add(order)
    await db.commit()
    await notify_customer_no_vendor(db, order, background_tasks)
    return {
        "reassigned": False,
        "message": "No eligible vendor found. Customer has been notified.",
    }


async def process_pending_booking_timeouts(background_tasks=None) -> int:
    """
    Reassign bookings where the assigned vendor did not accept within ACCEPT_TIMEOUT_MINUTES.
    """
    from app.db.session import AsyncSessionLocal

    cutoff = datetime.utcnow() - timedelta(minutes=ACCEPT_TIMEOUT_MINUTES)
    processed = 0

    async with AsyncSessionLocal() as session:
        result = await session.execute(
            select(OrderModel).where(
                OrderModel.status.in_(["PENDING", "new"]),
                OrderModel.accepted_at.is_(None),
                OrderModel.vendor_id.isnot(None),
            )
        )
        orders = result.scalars().all()

        for order in orders:
            meta = _parse_assignment_meta(order.vendor_notes)
            assigned_at_str = meta.get("assigned_at")
            if not assigned_at_str:
                continue
            try:
                assigned_at = datetime.fromisoformat(assigned_at_str)
            except ValueError:
                continue
            if assigned_at > cutoff:
                continue

            await handle_vendor_decline_or_timeout(
                session,
                order,
                declined_vendor_id=order.vendor_id,
                reason="Auto-reassigned: vendor did not accept within "
                f"{ACCEPT_TIMEOUT_MINUTES} minutes",
                background_tasks=background_tasks,
                is_timeout=True,
            )
            processed += 1

    if processed:
        logger.info("Processed %d timed-out pending bookings for reassignment", processed)
    return processed
