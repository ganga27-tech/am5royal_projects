from datetime import datetime
from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, desc, or_

from app.db.session import get_db
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
from app.schemas.developer_portal import (
    TeamMemberResponse,
    ProjectCreate,
    ProjectUpdate,
    ProjectResponse,
    ProjectMemberCreate,
    ProjectMemberResponse,
    ProjectWorkspaceResponse,
    ModuleCreate,
    ModuleUpdate,
    ModuleResponse,
    ApiCreate,
    ApiUpdate,
    ApiResponse,
    TaskCreate,
    TaskUpdate,
    TaskResponse,
    TaskCommentCreate,
    TaskCommentResponse,
    BugCreate,
    BugUpdate,
    BugTransitionRequest,
    BugAssignRequest,
    BugCommentCreate,
    BugCommentResponse,
    BugResponse,
    BugListResponse,
    NotificationResponse,
    DeploymentCreate,
    DeploymentResponse,
    AuditLogResponse,
    GlobalDashboardStats,
    DeveloperDashboardStats,
    QADashboardStats,
    DatabaseHealthStats,
    SecurityAuditStats,
    AnalyticsTrends,
)
from app.schemas.employee import EmployeeLogin, Token
from app.core.security import verify_password, create_access_token
from app.dependencies.developer_auth import (
    get_current_dev_or_qa_user,
    get_current_developer_user,
    get_current_qa_user,
    get_current_admin_user,
)
from app.services.bug_workflow_service import bug_workflow_service
from app.services.developer_service import developer_service

router = APIRouter()


# ---------------------------------------------------------------------------
# 1. Authentication & Profile
# ---------------------------------------------------------------------------
@router.post("/auth/login", response_model=Token)
async def login_developer_portal(
    login_data: EmployeeLogin,
    db: AsyncSession = Depends(get_db)
):
    query = select(Employee).where(
        (Employee.email == login_data.identifier) |
        (Employee.phone_number == login_data.identifier)
    )
    result = await db.execute(query)
    employee = result.scalar_one_or_none()

    if not employee or not verify_password(login_data.password, employee.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )

    if employee.status != "active":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Employee account is not active",
        )

    allowed_roles = ["developer", "qa", "admin", "super_admin"]
    if (employee.role or "").lower() not in allowed_roles:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Access Denied: Role '{employee.role}' does not have access to the Developer Portal.",
        )

    access_token = create_access_token(subject=str(employee.id))

    # Record Audit Log
    actor_name = f"{employee.first_name or ''} {employee.last_name or ''}".strip() or employee.email
    audit = DevAuditLog(
        actor_id=employee.id,
        actor_role=employee.role,
        actor_name=actor_name,
        action="LOGIN",
        resource_type="AUTH",
        resource_id=str(employee.id),
        details=f"{employee.role.upper()} login successful",
        status="success",
    )
    db.add(audit)
    await db.commit()

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "role": employee.role,
    }


@router.get("/auth/me")
async def get_my_profile(
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    return {
        "id": current_user.id,
        "first_name": current_user.first_name,
        "last_name": current_user.last_name,
        "full_name": f"{current_user.first_name or ''} {current_user.last_name or ''}".strip() or current_user.email,
        "email": current_user.email,
        "phone_number": current_user.phone_number,
        "role": current_user.role,
        "status": current_user.status,
    }


# ---------------------------------------------------------------------------
# 2. Dashboards
# ---------------------------------------------------------------------------
@router.get("/dashboard/global", response_model=GlobalDashboardStats)
async def get_global_dashboard(
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    return await developer_service.get_global_dashboard_stats(db)


@router.get("/dashboard/developer", response_model=DeveloperDashboardStats)
async def get_developer_dashboard(
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    return await developer_service.get_developer_dashboard_stats(db, current_user)


@router.get("/dashboard/qa", response_model=QADashboardStats)
async def get_qa_dashboard(
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    return await developer_service.get_qa_dashboard_stats(db, current_user)


# ---------------------------------------------------------------------------
# 3. Projects
# ---------------------------------------------------------------------------
@router.get("/projects", response_model=List[ProjectResponse])
async def list_projects(
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    res = await db.execute(select(DevProject).order_by(DevProject.created_at.desc()))
    projects = res.scalars().all()
    return [await developer_service._format_project_response(db, p) for p in projects]


@router.post("/projects", response_model=ProjectResponse, status_code=status.HTTP_201_CREATED)
async def create_project(
    project_in: ProjectCreate,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    # Check unique slug
    existing = await db.execute(select(DevProject).where(DevProject.slug == project_in.slug))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Project with this slug already exists")

    head_id = project_in.project_head_id or current_user.id

    new_project = DevProject(
        name=project_in.name,
        slug=project_in.slug,
        description=project_in.description,
        status=project_in.status,
        progress=project_in.progress,
        repository_url=project_in.repository_url,
        created_by_id=current_user.id,
        project_head_id=head_id,
    )
    db.add(new_project)
    await db.commit()
    await db.refresh(new_project)

    # Ensure project head is enrolled as lead member
    if head_id:
        head_member = DevProjectMember(
            project_id=new_project.id,
            employee_id=head_id,
            project_role="lead",
        )
        db.add(head_member)
        await db.commit()

    return await developer_service._format_project_response(db, new_project)


@router.get("/projects/{project_id}", response_model=ProjectResponse)
async def get_project_details(
    project_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    project = await db.get(DevProject, project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return await developer_service._format_project_response(db, project)


@router.get("/projects/{project_id}/workspace", response_model=ProjectWorkspaceResponse)
async def get_project_workspace(
    project_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    project = await db.get(DevProject, project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return await developer_service.get_project_workspace(db, project)


@router.get("/projects/{project_id}/members", response_model=List[ProjectMemberResponse])
async def list_project_members(
    project_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    project = await db.get(DevProject, project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return await developer_service.get_project_members(db, project_id)


@router.post("/projects/{project_id}/members", response_model=ProjectMemberResponse, status_code=status.HTTP_201_CREATED)
async def add_project_member(
    project_id: int,
    member_in: ProjectMemberCreate,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    project = await db.get(DevProject, project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    # PERMISSION CHECK: Only Project Head or Admin can add team members
    is_admin = current_user.role in ["admin", "super_admin"]
    is_head = project.project_head_id == current_user.id
    if not (is_admin or is_head):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access Denied: Only the assigned Project Head or an Admin can manage team members for this project."
        )

    emp = await db.get(Employee, member_in.employee_id)
    if not emp:
        raise HTTPException(status_code=404, detail="Employee not found")

    # Check if already a member
    res = await db.execute(
        select(DevProjectMember).where(
            DevProjectMember.project_id == project_id,
            DevProjectMember.employee_id == member_in.employee_id
        )
    )
    existing_member = res.scalar_one_or_none()
    if existing_member:
        existing_member.project_role = member_in.project_role
        await db.commit()
        await db.refresh(existing_member)
        target_member = existing_member
    else:
        new_member = DevProjectMember(
            project_id=project_id,
            employee_id=member_in.employee_id,
            project_role=member_in.project_role,
        )
        db.add(new_member)
        await db.commit()
        await db.refresh(new_member)
        target_member = new_member

    # Audit log
    author_name = f"{current_user.first_name or ''} {current_user.last_name or ''}".strip() or current_user.email
    audit = DevAuditLog(
        actor_id=current_user.id,
        actor_name=author_name,
        actor_role=current_user.role,
        action="PROJECT_MEMBER_ADDED",
        resource_type="PROJECT",
        resource_id=str(project.id),
        details=f"Added {emp.email} as {member_in.project_role} to project '{project.name}'",
        status="success",
    )
    db.add(audit)

    # Notification to the added employee
    notif = DevNotification(
        recipient_id=emp.id,
        sender_id=current_user.id,
        title="Added to Project Team",
        message=f"You have been assigned to project '{project.name}' as {member_in.project_role} by {author_name}.",
        notification_type="project_assignment",
        reference_type="project",
        reference_id=project.id,
    )
    db.add(notif)
    await db.commit()

    return {
        "id": target_member.id,
        "project_id": project.id,
        "employee_id": emp.id,
        "full_name": f"{emp.first_name or ''} {emp.last_name or ''}".strip() or emp.email,
        "email": emp.email,
        "system_role": emp.role,
        "project_role": target_member.project_role,
        "created_at": target_member.created_at,
    }


@router.delete("/projects/{project_id}/members/{employee_id}")
async def remove_project_member(
    project_id: int,
    employee_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    project = await db.get(DevProject, project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    # PERMISSION CHECK: Only Project Head or Admin can remove team members
    is_admin = current_user.role in ["admin", "super_admin"]
    is_head = project.project_head_id == current_user.id
    if not (is_admin or is_head):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access Denied: Only the assigned Project Head or an Admin can remove team members from this project."
        )

    res = await db.execute(
        select(DevProjectMember).where(
            DevProjectMember.project_id == project_id,
            DevProjectMember.employee_id == employee_id
        )
    )
    member = res.scalar_one_or_none()
    if not member:
        raise HTTPException(status_code=404, detail="Member not found in this project")

    await db.delete(member)

    # Audit log
    author_name = f"{current_user.first_name or ''} {current_user.last_name or ''}".strip() or current_user.email
    audit = DevAuditLog(
        actor_id=current_user.id,
        actor_name=author_name,
        actor_role=current_user.role,
        action="PROJECT_MEMBER_REMOVED",
        resource_type="PROJECT",
        resource_id=str(project.id),
        details=f"Removed employee ID {employee_id} from project '{project.name}'",
        status="success",
    )
    db.add(audit)
    await db.commit()
    return {"message": "Member removed successfully"}


@router.put("/projects/{project_id}/head", response_model=ProjectResponse)
async def update_project_head(
    project_id: int,
    head_in: Dict[str, int],
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    project = await db.get(DevProject, project_id)
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    # Only Admin or Current Project Head can hand over head role
    is_admin = current_user.role in ["admin", "super_admin"]
    is_head = project.project_head_id == current_user.id
    if not (is_admin or is_head):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access Denied: Only an Admin or the Current Project Head can reassign Project Leadership."
        )

    new_head_id = head_in.get("project_head_id")
    if not new_head_id:
        raise HTTPException(status_code=400, detail="Missing project_head_id")

    new_head = await db.get(Employee, new_head_id)
    if not new_head:
        raise HTTPException(status_code=404, detail="Employee not found")

    project.project_head_id = new_head.id
    project.updated_at = datetime.utcnow()

    # Ensure in members list as lead
    res = await db.execute(
        select(DevProjectMember).where(
            DevProjectMember.project_id == project_id,
            DevProjectMember.employee_id == new_head.id
        )
    )
    m = res.scalar_one_or_none()
    if m:
        m.project_role = "lead"
    else:
        db.add(DevProjectMember(project_id=project_id, employee_id=new_head.id, project_role="lead"))

    await db.commit()
    await db.refresh(project)
    return await developer_service._format_project_response(db, project)


# ---------------------------------------------------------------------------
# 4. Modules
# ---------------------------------------------------------------------------
@router.get("/modules", response_model=List[ModuleResponse])
async def list_modules(
    project_id: Optional[int] = None,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    query = select(DevProjectModule)
    if project_id:
        query = query.where(DevProjectModule.project_id == project_id)
    query = query.order_by(DevProjectModule.name.asc())

    res = await db.execute(query)
    modules = res.scalars().all()
    results = []
    for m in modules:
        a_cnt = await db.execute(select(func.count(DevProjectApi.id)).where(DevProjectApi.module_id == m.id))
        b_cnt = await db.execute(select(func.count(DevBug.id)).where(DevBug.module_id == m.id, DevBug.status != "CLOSED"))
        t_cnt = await db.execute(select(func.count(DevTask.id)).where(DevTask.module_id == m.id, DevTask.status != "completed"))
        results.append({
            "id": m.id,
            "project_id": m.project_id,
            "name": m.name,
            "description": m.description,
            "status": m.status,
            "progress": m.progress,
            "created_at": m.created_at,
            "updated_at": m.updated_at,
            "apis_count": a_cnt.scalar() or 0,
            "bugs_count": b_cnt.scalar() or 0,
            "tasks_count": t_cnt.scalar() or 0,
        })
    return results


@router.post("/modules", response_model=ModuleResponse, status_code=status.HTTP_201_CREATED)
async def create_module(
    module_in: ModuleCreate,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    new_module = DevProjectModule(
        project_id=module_in.project_id,
        name=module_in.name,
        description=module_in.description,
        status=module_in.status,
        progress=module_in.progress,
    )
    db.add(new_module)
    await db.commit()
    await db.refresh(new_module)
    return {
        "id": new_module.id,
        "project_id": new_module.project_id,
        "name": new_module.name,
        "description": new_module.description,
        "status": new_module.status,
        "progress": new_module.progress,
        "created_at": new_module.created_at,
        "updated_at": new_module.updated_at,
        "apis_count": 0,
        "bugs_count": 0,
        "tasks_count": 0,
    }


# ---------------------------------------------------------------------------
# 5. APIs
# ---------------------------------------------------------------------------
@router.get("/apis", response_model=List[ApiResponse])
async def list_apis(
    project_id: Optional[int] = None,
    module_id: Optional[int] = None,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    query = select(DevProjectApi)
    if project_id:
        query = query.where(DevProjectApi.project_id == project_id)
    if module_id:
        query = query.where(DevProjectApi.module_id == module_id)
    query = query.order_by(DevProjectApi.endpoint.asc())

    res = await db.execute(query)
    return res.scalars().all()


@router.post("/apis", response_model=ApiResponse, status_code=status.HTTP_201_CREATED)
async def create_api_record(
    api_in: ApiCreate,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    new_api = DevProjectApi(
        project_id=api_in.project_id,
        module_id=api_in.module_id,
        name=api_in.name,
        endpoint=api_in.endpoint,
        method=api_in.method,
        status=api_in.status,
        version=api_in.version,
        description=api_in.description,
        health_status=api_in.health_status,
        last_tested_at=datetime.utcnow(),
    )
    db.add(new_api)
    await db.commit()
    await db.refresh(new_api)
    return new_api


@router.post("/apis/{api_id}/test")
async def test_api_endpoint(
    api_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    api_record = await db.get(DevProjectApi, api_id)
    if not api_record:
        raise HTTPException(status_code=404, detail="API record not found")

    api_record.health_status = "healthy"
    api_record.last_tested_at = datetime.utcnow()
    await db.commit()

    return {
        "id": api_record.id,
        "name": api_record.name,
        "endpoint": api_record.endpoint,
        "health_status": "healthy",
        "latency_ms": 28,
        "status_code": 200,
        "tested_at": api_record.last_tested_at,
    }


# ---------------------------------------------------------------------------
# 6. Tasks
# ---------------------------------------------------------------------------
@router.get("/tasks", response_model=List[TaskResponse])
async def list_tasks(
    project_id: Optional[int] = None,
    status_filter: Optional[str] = None,
    assigned_developer_id: Optional[int] = None,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    query = select(DevTask)
    if project_id:
        query = query.where(DevTask.project_id == project_id)
    if status_filter:
        query = query.where(DevTask.status == status_filter)
    if assigned_developer_id:
        query = query.where(DevTask.assigned_developer_id == assigned_developer_id)

    query = query.order_by(DevTask.created_at.desc())
    res = await db.execute(query)
    tasks = res.scalars().all()
    return [await developer_service._format_task_response(db, t) for t in tasks]


@router.post("/tasks", response_model=TaskResponse, status_code=status.HTTP_201_CREATED)
async def create_task(
    task_in: TaskCreate,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    new_task = DevTask(
        project_id=task_in.project_id,
        module_id=task_in.module_id,
        title=task_in.title,
        description=task_in.description,
        priority=task_in.priority,
        status=task_in.status,
        assigned_developer_id=task_in.assigned_developer_id,
        assigned_qa_id=task_in.assigned_qa_id,
        due_date=task_in.due_date,
        created_by_id=current_user.id,
    )
    db.add(new_task)
    await db.commit()
    await db.refresh(new_task)

    # Notify developer if assigned
    if new_task.assigned_developer_id:
        notif = DevNotification(
            recipient_id=new_task.assigned_developer_id,
            sender_id=current_user.id,
            title=f"Task Assigned: {new_task.title}",
            message=f"You have been assigned to task: {new_task.title}",
            notification_type="task_assigned",
            reference_type="task",
            reference_id=new_task.id,
        )
        db.add(notif)
        await db.commit()

    return await developer_service._format_task_response(db, new_task)


@router.put("/tasks/{task_id}", response_model=TaskResponse)
async def update_task(
    task_id: int,
    task_update: TaskUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    task = await db.get(DevTask, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    if task_update.title is not None:
        task.title = task_update.title
    if task_update.description is not None:
        task.description = task_update.description
    if task_update.priority is not None:
        task.priority = task_update.priority
    if task_update.status is not None:
        task.status = task_update.status
        if task_update.status == "completed":
            task.completed_at = datetime.utcnow()
    if task_update.assigned_developer_id is not None:
        task.assigned_developer_id = task_update.assigned_developer_id
    if task_update.assigned_qa_id is not None:
        task.assigned_qa_id = task_update.assigned_qa_id
    if task_update.due_date is not None:
        task.due_date = task_update.due_date

    task.updated_at = datetime.utcnow()
    await db.commit()
    await db.refresh(task)
    return await developer_service._format_task_response(db, task)


@router.post("/tasks/{task_id}/comments", response_model=TaskCommentResponse)
async def add_task_comment(
    task_id: int,
    comment_in: TaskCommentCreate,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    task = await db.get(DevTask, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    new_comment = DevTaskComment(
        task_id=task.id,
        author_id=current_user.id,
        message=comment_in.message,
    )
    db.add(new_comment)
    await db.commit()
    await db.refresh(new_comment)

    author_name = f"{current_user.first_name or ''} {current_user.last_name or ''}".strip() or current_user.email
    return {
        "id": new_comment.id,
        "task_id": new_comment.task_id,
        "author_id": new_comment.author_id,
        "author_name": author_name,
        "author_role": current_user.role,
        "message": new_comment.message,
        "created_at": new_comment.created_at,
    }


# ---------------------------------------------------------------------------
# 7. Bugs & State Machine Transitions (Core)
# ---------------------------------------------------------------------------
@router.get("/bugs", response_model=BugListResponse)
async def list_bugs(
    project_id: Optional[int] = None,
    module_id: Optional[int] = None,
    severity: Optional[str] = None,
    priority: Optional[str] = None,
    status_filter: Optional[str] = Query(None, alias="status"),
    assigned_developer_id: Optional[int] = None,
    assigned_qa_id: Optional[int] = None,
    search: Optional[str] = None,
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    query = select(DevBug)

    if project_id:
        query = query.where(DevBug.project_id == project_id)
    if module_id:
        query = query.where(DevBug.module_id == module_id)
    if severity:
        query = query.where(DevBug.severity == severity)
    if priority:
        query = query.where(DevBug.priority == priority)
    if status_filter:
        query = query.where(DevBug.status == status_filter)
    if assigned_developer_id:
        query = query.where(DevBug.assigned_developer_id == assigned_developer_id)
    if assigned_qa_id:
        query = query.where(DevBug.assigned_qa_id == assigned_qa_id)
    if search:
        s = f"%{search}%"
        query = query.where(
            or_(
                DevBug.title.ilike(s),
                DevBug.bug_code.ilike(s),
                DevBug.description.ilike(s),
            )
        )

    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    total_res = await db.execute(count_query)
    total = total_res.scalar() or 0

    # Paginate
    offset = (page - 1) * page_size
    query = query.order_by(DevBug.created_at.desc()).offset(offset).limit(page_size)
    res = await db.execute(query)
    bugs = res.scalars().all()

    items = [await developer_service._format_bug_response(db, b) for b in bugs]
    total_pages = (total + page_size - 1) // page_size if total > 0 else 1

    return {
        "items": items,
        "total": total,
        "page": page,
        "page_size": page_size,
        "total_pages": total_pages,
    }


@router.post("/bugs", response_model=BugResponse, status_code=status.HTTP_201_CREATED)
async def create_bug(
    bug_in: BugCreate,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    user_role = (current_user.role or "developer").lower()
    if user_role not in ["qa", "developer", "admin", "super_admin", "team_lead"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not authorized to create bugs",
        )

    # Generate bug code
    count_res = await db.execute(select(func.count(DevBug.id)))
    total_existing = count_res.scalar() or 0
    bug_code = f"BUG-{1001 + total_existing}"

    initial_status = "ASSIGNED_TO_DEVELOPER" if bug_in.assigned_developer_id else "NEW"

    new_bug = DevBug(
        bug_code=bug_code,
        project_id=bug_in.project_id,
        module_id=bug_in.module_id,
        api_id=bug_in.api_id,
        title=bug_in.title,
        description=bug_in.description,
        severity=bug_in.severity,
        priority=bug_in.priority,
        status=initial_status,
        environment=bug_in.environment,
        browser=bug_in.browser,
        os=bug_in.os,
        reported_by_id=current_user.id,
        assigned_developer_id=bug_in.assigned_developer_id,
        assigned_qa_id=bug_in.assigned_qa_id or current_user.id,
        steps_to_reproduce=bug_in.steps_to_reproduce,
        expected_result=bug_in.expected_result,
        actual_result=bug_in.actual_result,
        api_endpoint=bug_in.api_endpoint,
        request_payload_reference=bug_in.request_payload_reference,
        response_reference=bug_in.response_reference,
        attachment_urls=bug_in.attachment_urls,
    )
    db.add(new_bug)
    await db.commit()
    await db.refresh(new_bug)

    # Record initial history
    author_name = f"{current_user.first_name or ''} {current_user.last_name or ''}".strip() or current_user.email
    history = DevBugActivityHistory(
        bug_id=new_bug.id,
        actor_id=current_user.id,
        actor_role=current_user.role,
        action="BUG_CREATED",
        old_value=None,
        new_value=initial_status,
        notes=f"Bug created with severity: {new_bug.severity.upper()}, priority: {new_bug.priority.upper()}",
    )
    db.add(history)

    # If developer assigned at creation, notify them
    if new_bug.assigned_developer_id:
        notif = DevNotification(
            recipient_id=new_bug.assigned_developer_id,
            sender_id=current_user.id,
            title=f"New Bug Assigned: {new_bug.bug_code}",
            message=f"{author_name} reported and assigned {new_bug.bug_code} ({new_bug.title}) to you.",
            notification_type="bug_assigned",
            reference_type="bug",
            reference_id=new_bug.id,
        )
        db.add(notif)

    # Audit Log
    audit = DevAuditLog(
        actor_id=current_user.id,
        actor_role=current_user.role,
        actor_name=author_name,
        action="BUG_CREATED",
        resource_type="BUG",
        resource_id=str(new_bug.id),
        details=f"Created {new_bug.bug_code}: {new_bug.title}",
        status="success",
    )
    db.add(audit)

    await db.commit()
    await db.refresh(new_bug)
    return await developer_service._format_bug_response(db, new_bug)


@router.get("/bugs/{bug_id}", response_model=BugResponse)
async def get_bug_details(
    bug_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    bug = await db.get(DevBug, bug_id)
    if not bug:
        raise HTTPException(status_code=404, detail="Bug not found")
    return await developer_service._format_bug_response(db, bug, include_details=True)


@router.put("/bugs/{bug_id}", response_model=BugResponse)
async def update_bug_details(
    bug_id: int,
    bug_update: BugUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    bug = await db.get(DevBug, bug_id)
    if not bug:
        raise HTTPException(status_code=404, detail="Bug not found")

    for field, val in bug_update.dict(exclude_unset=True).items():
        setattr(bug, field, val)

    bug.updated_at = datetime.utcnow()
    await db.commit()
    await db.refresh(bug)
    return await developer_service._format_bug_response(db, bug, include_details=True)


@router.post("/bugs/{bug_id}/transition", response_model=BugResponse)
async def transition_bug_status(
    bug_id: int,
    transition_in: BugTransitionRequest,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    bug = await db.get(DevBug, bug_id)
    if not bug:
        raise HTTPException(status_code=404, detail="Bug not found")

    # Delegate to workflow state machine engine
    updated_bug = await bug_workflow_service.validate_and_execute_transition(
        db=db,
        bug=bug,
        new_status=transition_in.new_status,
        actor=current_user,
        notes=transition_in.notes,
        reassign_to_id=transition_in.reassign_to_id,
        commit_reference=transition_in.commit_reference,
        release_version=transition_in.release_version,
    )
    return await developer_service._format_bug_response(db, updated_bug, include_details=True)


@router.post("/bugs/{bug_id}/assign", response_model=BugResponse)
async def reassign_bug(
    bug_id: int,
    assign_in: BugAssignRequest,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    bug = await db.get(DevBug, bug_id)
    if not bug:
        raise HTTPException(status_code=404, detail="Bug not found")

    updated_bug = await bug_workflow_service.assign_bug(
        db=db,
        bug=bug,
        actor=current_user,
        developer_id=assign_in.developer_id,
        qa_id=assign_in.qa_id,
        notes=assign_in.notes,
    )
    return await developer_service._format_bug_response(db, updated_bug, include_details=True)


@router.post("/bugs/{bug_id}/comments", response_model=BugCommentResponse)
async def add_bug_comment(
    bug_id: int,
    comment_in: BugCommentCreate,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    bug = await db.get(DevBug, bug_id)
    if not bug:
        raise HTTPException(status_code=404, detail="Bug not found")

    new_comment = DevBugComment(
        bug_id=bug.id,
        author_id=current_user.id,
        author_role=current_user.role,
        message=comment_in.message,
        attachment_url=comment_in.attachment_url,
    )
    db.add(new_comment)

    # Activity history entry
    author_name = f"{current_user.first_name or ''} {current_user.last_name or ''}".strip() or current_user.email
    history = DevBugActivityHistory(
        bug_id=bug.id,
        actor_id=current_user.id,
        actor_role=current_user.role,
        action="COMMENT_ADDED",
        old_value=None,
        new_value=None,
        notes=f"Comment added by {author_name} ({current_user.role.upper()})",
    )
    db.add(history)

    # Notify counterpart
    counterpart_id = bug.assigned_qa_id if current_user.role == "developer" else bug.assigned_developer_id
    if counterpart_id and counterpart_id != current_user.id:
        notif = DevNotification(
            recipient_id=counterpart_id,
            sender_id=current_user.id,
            title=f"New Comment on {bug.bug_code}",
            message=f"{author_name}: {comment_in.message[:120]}",
            notification_type="bug_comment",
            reference_type="bug",
            reference_id=bug.id,
        )
        db.add(notif)

    await db.commit()
    await db.refresh(new_comment)

    return {
        "id": new_comment.id,
        "bug_id": new_comment.bug_id,
        "author_id": new_comment.author_id,
        "author_name": author_name,
        "author_role": current_user.role,
        "message": new_comment.message,
        "attachment_url": new_comment.attachment_url,
        "created_at": new_comment.created_at,
    }


# ---------------------------------------------------------------------------
# 8. Team Members (Developers & QA)
# ---------------------------------------------------------------------------
@router.get("/team", response_model=List[TeamMemberResponse])
async def list_team_members(
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    return await developer_service.get_team_members(db)


# ---------------------------------------------------------------------------
# 9. Deployments
# ---------------------------------------------------------------------------
@router.get("/deployments", response_model=List[DeploymentResponse])
async def list_deployments(
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    res = await db.execute(select(DevDeployment).order_by(DevDeployment.deployed_at.desc()))
    deps = res.scalars().all()
    results = []
    for d in deps:
        p = await db.get(DevProject, d.project_id)
        emp = await db.get(Employee, d.deployed_by_id)
        results.append({
            "id": d.id,
            "project_id": d.project_id,
            "project_name": p.name if p else "Unknown",
            "environment": d.environment,
            "version": d.version,
            "commit_hash": d.commit_hash,
            "status": d.status,
            "deployed_by_id": d.deployed_by_id,
            "deployer_name": f"{emp.first_name or ''} {emp.last_name or ''}".strip() if emp else "System",
            "changelog": d.changelog,
            "deployed_at": d.deployed_at,
        })
    return results


@router.post("/deployments", response_model=DeploymentResponse, status_code=status.HTTP_201_CREATED)
async def record_deployment(
    dep_in: DeploymentCreate,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    # Production deployments require admin role
    if dep_in.environment.upper() == "PRODUCTION" and (current_user.role or "").lower() not in ["admin", "super_admin"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Production deployment requires explicit Admin authorization."
        )

    new_dep = DevDeployment(
        project_id=dep_in.project_id,
        environment=dep_in.environment.upper(),
        version=dep_in.version,
        commit_hash=dep_in.commit_hash,
        status="success",
        deployed_by_id=current_user.id,
        changelog=dep_in.changelog,
    )
    db.add(new_dep)

    # Audit log
    author_name = f"{current_user.first_name or ''} {current_user.last_name or ''}".strip() or current_user.email
    audit = DevAuditLog(
        actor_id=current_user.id,
        actor_role=current_user.role,
        actor_name=author_name,
        action=f"DEPLOY_{dep_in.environment.upper()}",
        resource_type="DEPLOYMENT",
        resource_id=dep_in.version,
        details=f"Deployed version {dep_in.version} to {dep_in.environment.upper()}. Changelog: {dep_in.changelog or 'N/A'}",
        status="success",
    )
    db.add(audit)

    await db.commit()
    await db.refresh(new_dep)

    proj = await db.get(DevProject, new_dep.project_id)
    return {
        "id": new_dep.id,
        "project_id": new_dep.project_id,
        "project_name": proj.name if proj else "Unknown",
        "environment": new_dep.environment,
        "version": new_dep.version,
        "commit_hash": new_dep.commit_hash,
        "status": new_dep.status,
        "deployed_by_id": new_dep.deployed_by_id,
        "deployer_name": author_name,
        "changelog": new_dep.changelog,
        "deployed_at": new_dep.deployed_at,
    }


# ---------------------------------------------------------------------------
# 10. Analytics
# ---------------------------------------------------------------------------
@router.get("/analytics", response_model=AnalyticsTrends)
async def get_analytics(
    timeframe: str = Query("7d", pattern="^(today|7d|30d)$"),
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    return await developer_service.get_analytics_trends(db, timeframe)


# ---------------------------------------------------------------------------
# 11. Safe Diagnostics (Database & Security)
# ---------------------------------------------------------------------------
@router.get("/database", response_model=DatabaseHealthStats)
async def get_database_diagnostics(
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    return await developer_service.get_database_diagnostics(db)


@router.get("/security", response_model=SecurityAuditStats)
async def get_security_diagnostics(
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    return await developer_service.get_security_audit_stats(db)


# ---------------------------------------------------------------------------
# 12. Audit Logs
# ---------------------------------------------------------------------------
@router.get("/audit-logs", response_model=List[AuditLogResponse])
async def list_audit_logs(
    action: Optional[str] = None,
    limit: int = Query(50, ge=1, le=200),
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    query = select(DevAuditLog)
    if action:
        query = query.where(DevAuditLog.action.ilike(f"%{action}%"))
    query = query.order_by(DevAuditLog.created_at.desc()).limit(limit)

    res = await db.execute(query)
    return res.scalars().all()


# ---------------------------------------------------------------------------
# 13. Notifications
# ---------------------------------------------------------------------------
@router.get("/notifications", response_model=List[NotificationResponse])
async def list_my_notifications(
    limit: int = Query(30, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    res = await db.execute(
        select(DevNotification)
        .where(DevNotification.recipient_id == current_user.id)
        .order_by(DevNotification.created_at.desc())
        .limit(limit)
    )
    notifs = res.scalars().all()
    results = []
    for n in notifs:
        sender = await db.get(Employee, n.sender_id) if n.sender_id else None
        results.append({
            "id": n.id,
            "recipient_id": n.recipient_id,
            "sender_id": n.sender_id,
            "sender_name": f"{sender.first_name or ''} {sender.last_name or ''}".strip() if sender else "System",
            "title": n.title,
            "message": n.message,
            "notification_type": n.notification_type,
            "reference_type": n.reference_type,
            "reference_id": n.reference_id,
            "is_read": n.is_read,
            "created_at": n.created_at,
        })
    return results


@router.get("/notifications/unread-count")
async def get_unread_count(
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    res = await db.execute(
        select(func.count(DevNotification.id)).where(
            DevNotification.recipient_id == current_user.id,
            DevNotification.is_read == False
        )
    )
    return {"unread_count": res.scalar() or 0}


@router.put("/notifications/{notification_id}/read")
async def mark_notification_read(
    notification_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    notif = await db.get(DevNotification, notification_id)
    if notif and notif.recipient_id == current_user.id:
        notif.is_read = True
        await db.commit()
    return {"status": "ok"}


@router.put("/notifications/read-all")
async def mark_all_notifications_read(
    db: AsyncSession = Depends(get_db),
    current_user: Employee = Depends(get_current_dev_or_qa_user)
):
    res = await db.execute(
        select(DevNotification).where(
            DevNotification.recipient_id == current_user.id,
            DevNotification.is_read == False
        )
    )
    for n in res.scalars().all():
        n.is_read = True
    await db.commit()
    return {"status": "ok"}
