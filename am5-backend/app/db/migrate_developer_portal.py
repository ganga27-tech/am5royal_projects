"""
Idempotent migration and seed script for the AM5 Royal Developer Portal.
Safely creates all dev_* tables and seeds initial development and QA assets.
"""
import asyncio
from datetime import datetime, timedelta
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.base_class import Base
from app.db.session import engine, AsyncSessionLocal
from app.core.security import get_password_hash
from app.models.employee import Employee
from app.models.developer_portal import (
    DevProject,
    DevProjectMember,
    DevProjectModule,
    DevProjectApi,
    DevTask,
    DevTaskComment,
    DevBug,
    DevBugComment,
    DevBugActivityHistory,
    DevNotification,
    DevDeployment,
    DevAuditLog,
)


async def main():
    print("Ensuring Developer Portal tables...")
    async with engine.begin() as conn:
        await conn.run_sync(
            Base.metadata.create_all,
            tables=[
                DevProject.__table__,
                DevProjectMember.__table__,
                DevProjectModule.__table__,
                DevProjectApi.__table__,
                DevTask.__table__,
                DevTaskComment.__table__,
                DevBug.__table__,
                DevBugComment.__table__,
                DevBugActivityHistory.__table__,
                DevNotification.__table__,
                DevDeployment.__table__,
                DevAuditLog.__table__,
            ],
        )
    print("Developer Portal tables ensured successfully.")

    async with AsyncSessionLocal() as db:
        # 1. Seed or retrieve Developer & QA employees
        dev_user = await get_or_create_employee(
            db,
            email="dev@am5royal.com",
            phone="9876543210",
            first_name="Vishal",
            last_name="Developer",
            password="Dev@am5royal2026",
            role="developer",
        )

        qa_user = await get_or_create_employee(
            db,
            email="qa@am5royal.com",
            phone="9876543211",
            first_name="Sarah",
            last_name="QA Lead",
            password="Qa@am5royal2026",
            role="qa",
        )

        admin_user = await get_or_create_employee(
            db,
            email="admin@am5royal.com",
            phone="9876543212",
            first_name="Royal",
            last_name="Admin",
            password="Admin@am5royal2026",
            role="admin",
        )

        # 2. Check if projects already exist
        p_res = await db.execute(select(DevProject).limit(1))
        if p_res.scalars().first():
            print("Developer portal data already seeded. Skipping initial fixtures.")
            return

        print("Seeding initial Developer Portal projects, modules, APIs, tasks, and bugs...")

        # Projects
        backend_proj = DevProject(
            name="AM5 Royal Marketplace Backend",
            slug="am5-backend",
            description="Core FastAPI asynchronous services, PostgreSQL, Redis, and Airtel IQ integration.",
            status="active",
            progress=88,
            repository_url="https://github.com/freelancerapp-max/fb",
            created_by_id=admin_user.id,
        )
        telecaller_proj = DevProject(
            name="AM5 Royal Telecaller Panel",
            slug="telecaller-panel",
            description="Agent telecaller operations console for vendor onboarding, tracking, and incentives.",
            status="active",
            progress=92,
            repository_url="https://github.com/freelancerapp-max/fb/panels/telecaller",
            created_by_id=admin_user.id,
        )
        dev_panel_proj = DevProject(
            name="AM5 Royal Developer Panel",
            slug="developer-panel",
            description="Production-grade developer and QA defect tracking, API catalog, and control center.",
            status="in_progress",
            progress=75,
            repository_url="https://github.com/freelancerapp-max/fb/panels/developer",
            created_by_id=admin_user.id,
        )
        vendor_proj = DevProject(
            name="AM5 Royal Vendor Web App",
            slug="vendor-app",
            description="Vendor onboarding, verification, profile maintenance, and subscription management.",
            status="active",
            progress=85,
            repository_url="https://am5vendor.web.app",
            created_by_id=admin_user.id,
        )
        db.add_all([backend_proj, telecaller_proj, dev_panel_proj, vendor_proj])
        await db.commit()
        await db.refresh(backend_proj)
        await db.refresh(telecaller_proj)
        await db.refresh(dev_panel_proj)
        await db.refresh(vendor_proj)

        # Modules
        m_auth = DevProjectModule(
            project_id=backend_proj.id,
            name="Authentication & Authorization",
            description="JWT issuance, token revocation, RBAC security layer, and customer/vendor/employee auth.",
            status="active",
            progress=95,
        )
        m_catalog = DevProjectModule(
            project_id=backend_proj.id,
            name="Vendor & Service Catalog",
            description="Hierarchical service packages, dynamic pricing, and city-based catalog filters.",
            status="active",
            progress=90,
        )
        m_orders = DevProjectModule(
            project_id=backend_proj.id,
            name="Orders & Payment Gateway",
            description="Booking creation, Razorpay webhooks, customer wallet, and settlement ledger.",
            status="in_progress",
            progress=82,
        )
        m_telecall = DevProjectModule(
            project_id=telecaller_proj.id,
            name="Call Dispatch & Audio Recording",
            description="Airtel IQ telephony API click-to-call, automated call logging, and recording playback.",
            status="active",
            progress=94,
        )
        m_ai = DevProjectModule(
            project_id=backend_proj.id,
            name="AI Automated Verification",
            description="Gemini-assisted OCR for Aadhaar/PAN and facial consistency scoring.",
            status="active",
            progress=86,
        )
        db.add_all([m_auth, m_catalog, m_orders, m_telecall, m_ai])
        await db.commit()
        await db.refresh(m_auth)
        await db.refresh(m_catalog)
        await db.refresh(m_orders)
        await db.refresh(m_telecall)
        await db.refresh(m_ai)

        # APIs
        apis = [
            DevProjectApi(
                project_id=backend_proj.id,
                module_id=m_auth.id,
                name="Vendor / Customer Auth Login",
                endpoint="/api/v1/auth/login",
                method="POST",
                status="active",
                version="v1",
                description="Authenticate user with phone number and OTP or password.",
                health_status="healthy",
                last_tested_at=datetime.utcnow(),
            ),
            DevProjectApi(
                project_id=backend_proj.id,
                module_id=m_catalog.id,
                name="Service Categories List",
                endpoint="/api/v1/catalog/categories",
                method="GET",
                status="active",
                version="v1",
                description="List all active service categories and packages by city.",
                health_status="healthy",
                last_tested_at=datetime.utcnow(),
            ),
            DevProjectApi(
                project_id=backend_proj.id,
                module_id=m_orders.id,
                name="Create Order Booking",
                endpoint="/api/v1/orders",
                method="POST",
                status="active",
                version="v1",
                description="Submit booking request and initialize payment transaction.",
                health_status="healthy",
                last_tested_at=datetime.utcnow(),
            ),
            DevProjectApi(
                project_id=telecaller_proj.id,
                module_id=m_telecall.id,
                name="Initiate Airtel IQ Click-to-Call",
                endpoint="/api/v1/employees/calls/initiate",
                method="POST",
                status="active",
                version="v1",
                description="Connect telecaller agent to vendor via outbound bridge.",
                health_status="healthy",
                last_tested_at=datetime.utcnow(),
            ),
            DevProjectApi(
                project_id=backend_proj.id,
                module_id=m_ai.id,
                name="Verify KYC Document with AI",
                endpoint="/api/v1/ai/verify-document",
                method="POST",
                status="active",
                version="v1",
                description="Extract details from Aadhaar/PAN and score authenticity.",
                health_status="healthy",
                last_tested_at=datetime.utcnow(),
            ),
        ]
        db.add_all(apis)
        await db.commit()

        # Tasks
        tasks = [
            DevTask(
                project_id=backend_proj.id,
                module_id=m_orders.id,
                title="Implement Razorpay webhook signature verification",
                description="Ensure idempotency and cryptographic signature validation on Razorpay payment captures.",
                priority="critical",
                status="completed",
                assigned_developer_id=dev_user.id,
                assigned_qa_id=qa_user.id,
                completed_at=datetime.utcnow() - timedelta(days=2),
                created_by_id=admin_user.id,
            ),
            DevTask(
                project_id=backend_proj.id,
                module_id=m_orders.id,
                title="Add refund calculation engine for cancelled bookings",
                description="Implement tiered refund policy: 100% before 2 hours, 50% within 1 hour.",
                priority="high",
                status="in_progress",
                assigned_developer_id=dev_user.id,
                assigned_qa_id=qa_user.id,
                due_date=datetime.utcnow() + timedelta(days=3),
                created_by_id=admin_user.id,
            ),
            DevTask(
                project_id=telecaller_proj.id,
                module_id=m_telecall.id,
                title="Cache Airtel token in Redis to avoid throttling",
                description="Token expires every 24 hours; store in Redis with TTL 23h.",
                priority="medium",
                status="todo",
                assigned_developer_id=dev_user.id,
                assigned_qa_id=qa_user.id,
                due_date=datetime.utcnow() + timedelta(days=5),
                created_by_id=admin_user.id,
            ),
        ]
        db.add_all(tasks)
        await db.commit()

        # Bugs (Across lifecycle states for end-to-end testing)
        bug1 = DevBug(
            bug_code="BUG-1001",
            project_id=backend_proj.id,
            module_id=m_orders.id,
            title="Booking API returns 500 when vendor has no schedule configured",
            description="When a customer places a booking for a vendor who hasn't defined availability intervals, the backend crashes with a NoneType error.",
            severity="high",
            priority="critical",
            status="IN_PROGRESS",
            environment="staging",
            browser="Chrome 128",
            os="macOS Sequoia",
            reported_by_id=qa_user.id,
            assigned_developer_id=dev_user.id,
            assigned_qa_id=qa_user.id,
            steps_to_reproduce="1. Log in as customer.\n2. Pick vendor ID 44 (no schedule set).\n3. Click 'Book Service'.\n4. Observe 500 Internal Server Error.",
            expected_result="Return 400 Bad Request with message 'Vendor is currently unavailable'.",
            actual_result="500 Internal Server Error with unhandled NoneType exception.",
            technical_notes="Check app/api/v1/endpoints/orders.py: line 142 availability query.",
            api_endpoint="/api/v1/orders",
        )

        bug2 = DevBug(
            bug_code="BUG-1002",
            project_id=backend_proj.id,
            module_id=m_auth.id,
            title="CORS preflight rejection on dynamic Vercel preview URLs",
            description="Preview deployments (*.vercel.app) fail preflight CORS requests with 403 Forbidden.",
            severity="medium",
            priority="high",
            status="VERIFIED",
            environment="production",
            reported_by_id=qa_user.id,
            assigned_developer_id=dev_user.id,
            assigned_qa_id=qa_user.id,
            steps_to_reproduce="Send OPTIONS request from preview origin https://fb-chi-nine.vercel.app",
            expected_result="200 OK with Access-Control-Allow-Origin header.",
            actual_result="CORS error in browser console.",
            fixed_at=datetime.utcnow() - timedelta(hours=3),
            verified_at=datetime.utcnow() - timedelta(hours=1),
            closed_at=datetime.utcnow() - timedelta(minutes=30),
            commit_reference="c09f507",
        )

        bug3 = DevBug(
            bug_code="BUG-1003",
            project_id=telecaller_proj.id,
            module_id=m_telecall.id,
            title="Call duration calculation off by 5 seconds on Airtel webhook",
            description="Agent call timer starts on dial instead of answered state.",
            severity="medium",
            priority="medium",
            status="READY_FOR_QA",
            environment="development",
            reported_by_id=qa_user.id,
            assigned_developer_id=dev_user.id,
            assigned_qa_id=qa_user.id,
            steps_to_reproduce="Place test call and let it ring for 10 seconds before answering.",
            expected_result="Recorded duration equals talk-time only.",
            actual_result="Duration includes ringing time.",
            fixed_at=datetime.utcnow() - timedelta(hours=2),
            developer_notes="Fixed webhook timestamp delta calculation.",
        )

        bug4 = DevBug(
            bug_code="BUG-1004",
            project_id=backend_proj.id,
            module_id=m_auth.id,
            title="Duplicate SMS sent on rapid double-click of OTP request",
            description="No debounce or rate limiter on the frontend resend OTP button allows sending two SMS messages within 100ms.",
            severity="low",
            priority="medium",
            status="NEW",
            environment="development",
            reported_by_id=qa_user.id,
            assigned_developer_id=None,
            assigned_qa_id=qa_user.id,
            steps_to_reproduce="Double click 'Resend OTP' quickly on login modal.",
            expected_result="Only 1 SMS dispatched, button disabled for 30 seconds.",
            actual_result="2 SMS messages received.",
        )

        bug5 = DevBug(
            bug_code="BUG-1005",
            project_id=vendor_proj.id,
            title="Vendor profile picture upload fails on iOS Safari webview",
            description="Multipart form upload sends empty boundary on certain iOS Safari versions.",
            severity="high",
            priority="high",
            status="QA_REJECTED",
            environment="staging",
            reported_by_id=qa_user.id,
            assigned_developer_id=dev_user.id,
            assigned_qa_id=qa_user.id,
            steps_to_reproduce="Open vendor onboarding in iOS Safari and upload PNG photo.",
            expected_result="Photo uploaded and thumbnail generated.",
            actual_result="Upload fails with 'Invalid multipart payload'.",
            qa_notes="Retested on iPhone 15 iOS 17.5. Issue still persists.",
            reopened_count=1,
        )

        db.add_all([bug1, bug2, bug3, bug4, bug5])
        await db.commit()
        await db.refresh(bug1)
        await db.refresh(bug2)
        await db.refresh(bug3)
        await db.refresh(bug4)
        await db.refresh(bug5)

        # Bug Activity History & Comments
        histories = [
            DevBugActivityHistory(
                bug_id=bug1.id,
                actor_id=qa_user.id,
                actor_role="qa",
                action="BUG_CREATED",
                old_value=None,
                new_value="ASSIGNED_TO_DEVELOPER",
                notes="Reported by QA and assigned to Dev Vishal",
            ),
            DevBugActivityHistory(
                bug_id=bug1.id,
                actor_id=dev_user.id,
                actor_role="developer",
                action="STATUS_CHANGED",
                old_value="ASSIGNED_TO_DEVELOPER",
                new_value="IN_PROGRESS",
                notes="Investigating availability check logic in orders router",
            ),
            DevBugActivityHistory(
                bug_id=bug3.id,
                actor_id=dev_user.id,
                actor_role="developer",
                action="READY_FOR_QA",
                old_value="IN_PROGRESS",
                new_value="READY_FOR_QA",
                notes="Fixed talk-time delta. Reassigned to QA for verification.",
            ),
            DevBugActivityHistory(
                bug_id=bug5.id,
                actor_id=qa_user.id,
                actor_role="qa",
                action="QA_REJECTED",
                old_value="READY_FOR_QA",
                new_value="QA_REJECTED",
                notes="Still failing on iOS Safari. Please inspect Content-Type header.",
            ),
        ]
        db.add_all(histories)

        comments = [
            DevBugComment(
                bug_id=bug1.id,
                author_id=qa_user.id,
                author_role="qa",
                message="Repro rate is 100% on staging with any vendor having an empty schedule.",
            ),
            DevBugComment(
                bug_id=bug1.id,
                author_id=dev_user.id,
                author_role="developer",
                message="Reproduced. The join on `vendor_availability` returns None when records are absent. Adding null safety check.",
            ),
            DevBugComment(
                bug_id=bug5.id,
                author_id=qa_user.id,
                author_role="qa",
                message="Tested on iOS 17.5. Reopening as multipart boundary is still missing.",
            ),
        ]
        db.add_all(comments)

        # Deployments
        deployments = [
            DevDeployment(
                project_id=backend_proj.id,
                environment="PRODUCTION",
                version="v1.4.2",
                commit_hash="c09f507",
                status="success",
                deployed_by_id=admin_user.id,
                changelog="CORS regex updates and slowapi rate limiting integration.",
                deployed_at=datetime.utcnow() - timedelta(hours=4),
            ),
            DevDeployment(
                project_id=telecaller_proj.id,
                environment="PRODUCTION",
                version="v1.2.0",
                commit_hash="81c391f",
                status="success",
                deployed_by_id=admin_user.id,
                changelog="Team members panel updates and call log improvements.",
                deployed_at=datetime.utcnow() - timedelta(days=1),
            ),
            DevDeployment(
                project_id=backend_proj.id,
                environment="STAGING",
                version="v1.5.0-rc1",
                commit_hash="d7a123f",
                status="success",
                deployed_by_id=dev_user.id,
                changelog="Career application endpoints and telecaller verification incentives.",
                deployed_at=datetime.utcnow() - timedelta(hours=12),
            ),
        ]
        db.add_all(deployments)

        # Initial Notifications
        notifs = [
            DevNotification(
                recipient_id=dev_user.id,
                sender_id=qa_user.id,
                title="Bug Assigned: BUG-1001",
                message="Sarah assigned BUG-1001 to you: Booking API returns 500 when vendor has no schedule.",
                notification_type="bug_assigned",
                reference_type="bug",
                reference_id=bug1.id,
                is_read=False,
            ),
            DevNotification(
                recipient_id=qa_user.id,
                sender_id=dev_user.id,
                title="BUG-1003 Ready for QA",
                message="Vishal fixed BUG-1003 and requested QA verification.",
                notification_type="bug_status_change",
                reference_type="bug",
                reference_id=bug3.id,
                is_read=False,
            ),
            DevNotification(
                recipient_id=dev_user.id,
                sender_id=qa_user.id,
                title="BUG-1005 QA Rejected",
                message="Sarah rejected fix for BUG-1005: Issue still reproduces on iOS Safari.",
                notification_type="bug_status_change",
                reference_type="bug",
                reference_id=bug5.id,
                is_read=False,
            ),
        ]
        db.add_all(notifs)

        # Initial Audit Logs
        audits = [
            DevAuditLog(
                actor_id=admin_user.id,
                actor_role="admin",
                actor_name="Royal Admin",
                action="INITIALIZE_DEVELOPER_PORTAL",
                resource_type="SYSTEM",
                resource_id="1",
                details="Seeded initial projects, modules, APIs, and test users.",
                status="success",
            ),
            DevAuditLog(
                actor_id=qa_user.id,
                actor_role="qa",
                actor_name="Sarah QA Lead",
                action="BUG_CREATED",
                resource_type="BUG",
                resource_id=str(bug1.id),
                details=f"Created {bug1.bug_code}: {bug1.title}",
                status="success",
            ),
        ]
        db.add_all(audits)

        await db.commit()
        print("Developer Portal seed completed successfully!")


async def get_or_create_employee(
    db: AsyncSession,
    email: str,
    phone: str,
    first_name: str,
    last_name: str,
    password: str,
    role: str,
) -> Employee:
    res = await db.execute(
        select(Employee).where(
            (Employee.email == email) | (Employee.phone_number == phone)
        )
    )
    emp = res.scalar_one_or_none()
    if not emp:
        emp = Employee(
            email=email,
            phone_number=phone,
            first_name=first_name,
            last_name=last_name,
            hashed_password=get_password_hash(password),
            role=role,
            status="active",
        )
        db.add(emp)
        await db.commit()
        await db.refresh(emp)
        print(f"Created {role.upper()} employee: {email}")
    else:
        # Ensure role is set properly
        if emp.role != role:
            emp.role = role
            await db.commit()
            await db.refresh(emp)
    return emp


if __name__ == "__main__":
    asyncio.run(main())
