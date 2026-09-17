import logging
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from app.db.session import AsyncSessionLocal
from sqlalchemy import select, func
from app.models.vendor import Vendor, VendorService, VendorDocument
from app.models.subscriptions import VendorSubscription
from app.models.user_location import User
from app.models.vendor_extras import VendorMonthlyHistory
from app.models.orders import Order
from app.services.notification_service import send_push_notification
from app.core.config import settings
from datetime import date, time, datetime, timedelta

logger = logging.getLogger(__name__)

async def get_incomplete_vendors():
    """
    Returns a list of dicts containing 'user_id', 'mobile', and 'missing_reason' for vendors
    who have not fully completed their onboarding process.
    """
    from sqlalchemy import exists
    async with AsyncSessionLocal() as session:
        incomplete_vendors = []
        
        # 1. Users with role VENDOR but no Vendor profile
        user_query = select(User).where(User.role == "VENDOR", ~User.id.in_(select(Vendor.user_id)))
        user_result = await session.execute(user_query)
        unprofiled_users = user_result.scalars().all()
        for user in unprofiled_users:
            if user.mobile:
                incomplete_vendors.append({
                    "user_id": user.id,
                    "mobile": user.mobile,
                    "missing_reason": "upload your documents to complete your KYC and activate your account"
                })
        
        # 2. Vendors with incomplete profiles - Optimized using exists() to avoid N+1 queries
        service_exists = exists().where(VendorService.vendor_id == Vendor.id)
        doc_exists = exists().where(VendorDocument.vendor_id == Vendor.id)
        sub_exists = exists().where(VendorSubscription.vendor_id == Vendor.id)
        
        query = select(
            Vendor, 
            User,
            service_exists.label("has_services"),
            doc_exists.label("has_docs"),
            sub_exists.label("has_sub")
        ).join(User, Vendor.user_id == User.id).where(
            Vendor.status == "active"
        )
        result = await session.execute(query)
        rows = result.all()
        
        for vendor, user, has_services, has_docs, has_sub in rows:
            missing_reason = None
            
            if not has_services:
                missing_reason = "Please select and add your services to complete your vendor profile."
            elif not has_docs:
                missing_reason = "Please upload your documents to complete your KYC and activate your account."
            elif not has_sub:
                missing_reason = "Last step to complete the payment and active your account."
            
            if missing_reason and user.mobile:
                incomplete_vendors.append({
                    "user_id": user.id,
                    "mobile": user.mobile,
                    "missing_reason": missing_reason
                })
                
        return incomplete_vendors

async def send_morning_service_reminders():
    logger.info("Running Morning Service/KYC Selection Reminder cron job (10 AM)...")
    vendors = await get_incomplete_vendors()
    async with AsyncSessionLocal() as session:
        for v in vendors:
            # Send push notification
            title = "AM5 Royal Account Activation"
            body = f"Good Morning! {v['missing_reason']}"
            await send_push_notification(user_id=v["user_id"], db=session, title=title, body=body)
            
    logger.info(f"Morning reminders sent to {len(vendors)} vendors.")

async def send_afternoon_service_reminders():
    logger.info("Running Afternoon Service/KYC Selection Reminder cron job (2 PM)...")
    vendors = await get_incomplete_vendors()
    async with AsyncSessionLocal() as session:
        for v in vendors:
            # Send push notification
            title = "AM5 Royal Account Activation"
            body = f"Good Afternoon! {v['missing_reason']}"
            await send_push_notification(user_id=v["user_id"], db=session, title=title, body=body)
            
    logger.info(f"Afternoon reminders sent to {len(vendors)} vendors.")

async def send_evening_service_reminders():
    logger.info("Running Evening Service/KYC Selection Reminder cron job (5 PM)...")
    vendors = await get_incomplete_vendors()
    async with AsyncSessionLocal() as session:
        for v in vendors:
            # Send push notification
            title = "AM5 Royal Account Activation"
            body = f"Good Evening! {v['missing_reason']}"
            await send_push_notification(user_id=v["user_id"], db=session, title=title, body=body)
            
    logger.info(f"Evening reminders sent to {len(vendors)} vendors.")

async def record_monthly_vendor_histories():
    logger.info("Running monthly vendor history logging cron job...")
    async with AsyncSessionLocal() as session:
        # Get last month string in format YYYY-MM
        today = date.today()
        # Find 1st of last month
        first_day_this_month = today.replace(day=1)
        last_day_last_month = first_day_this_month - timedelta(days=1)
        month_str = last_day_last_month.strftime("%Y-%m")
        start_of_last_month = datetime.combine(last_day_last_month.replace(day=1), time.min)
        end_of_last_month = datetime.combine(first_day_this_month, time.min) - timedelta(seconds=1)

        # Get all vendors
        vendors_query = select(Vendor)
        vendors_res = await session.execute(vendors_query)
        vendors = vendors_res.scalars().all()

        for v in vendors:
            # Query completed services count for last month
            count_query = select(func.count(Order.id)).where(
                Order.vendor_id == v.id,
                Order.status == 'completed',
                Order.created_at >= start_of_last_month,
                Order.created_at <= end_of_last_month
            )
            count = (await session.execute(count_query)).scalar() or 0

            # Query total earnings for last month
            earnings_query = select(func.sum(Order.total_amount)).where(
                Order.vendor_id == v.id,
                Order.status == 'completed',
                Order.created_at >= start_of_last_month,
                Order.created_at <= end_of_last_month
            )
            earnings = (await session.execute(earnings_query)).scalar() or 0.0

            # Create history record
            history = VendorMonthlyHistory(
                vendor_id=v.id,
                month=month_str,
                completed_services_count=count,
                total_earnings=earnings
            )
            session.add(history)

        await session.commit()
        logger.info(f"Recorded monthly history for {len(vendors)} vendors for month {month_str}.")

async def process_booking_acceptance_timeouts():
    """Reassign bookings when vendors do not accept within the timeout window."""
    from app.services.booking_assignment_service import process_pending_booking_timeouts
    try:
        count = await process_pending_booking_timeouts()
        if count:
            logger.info("Booking timeout cron reassigned %s orders", count)
    except Exception as e:
        logger.error("Booking timeout cron failed: %s", e)

scheduler = AsyncIOScheduler()

def setup_cron_jobs():
    # Schedule Service Selection & KYC Document Reminders at 10:00 AM, 2:00 PM, and 5:00 PM IST
    scheduler.add_job(send_morning_service_reminders, 'cron', hour=10, minute=0, timezone='Asia/Kolkata')
    scheduler.add_job(send_afternoon_service_reminders, 'cron', hour=14, minute=0, timezone='Asia/Kolkata')
    scheduler.add_job(send_evening_service_reminders, 'cron', hour=17, minute=0, timezone='Asia/Kolkata')
    scheduler.add_job(record_monthly_vendor_histories, 'cron', day=1, hour=0, minute=0, timezone='Asia/Kolkata')
    scheduler.add_job(process_booking_acceptance_timeouts, 'interval', minutes=5)
    
    scheduler.start()
    logger.info("APScheduler started with vendor reminder, history, and booking timeout cron jobs.")
