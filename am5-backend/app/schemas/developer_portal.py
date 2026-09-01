from datetime import datetime
from typing import List, Optional, Any, Dict
from pydantic import BaseModel, Field


# ---------------------------------------------------------------------------
# Employee / Team Member Schemas
# ---------------------------------------------------------------------------
class TeamMemberResponse(BaseModel):
    id: int
    first_name: str
    last_name: Optional[str] = None
    full_name: str
    email: str
    phone_number: Optional[str] = None
    role: str
    status: str
    active_bugs_count: int = 0
    completed_tasks_count: int = 0
    workload_score: int = 0  # 0 to 100

    class Config:
        from_attributes = True


# ---------------------------------------------------------------------------
# Project Schemas
# ---------------------------------------------------------------------------
class ProjectMemberCreate(BaseModel):
    employee_id: int
    project_role: str = "developer"  # developer, qa, lead, viewer


class ProjectMemberResponse(BaseModel):
    id: int
    project_id: int
    employee_id: int
    full_name: str
    email: str
    system_role: str
    project_role: str
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class ProjectBase(BaseModel):
    name: str
    slug: str
    description: Optional[str] = None
    status: str = "active"
    progress: int = Field(default=0, ge=0, le=100)
    repository_url: Optional[str] = None
    project_head_id: Optional[int] = None


class ProjectCreate(ProjectBase):
    pass


class ProjectUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None
    progress: Optional[int] = Field(default=None, ge=0, le=100)
    repository_url: Optional[str] = None
    project_head_id: Optional[int] = None


class ProjectResponse(ProjectBase):
    id: int
    created_by_id: Optional[int] = None
    project_head_name: Optional[str] = None
    project_head_email: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    modules_count: int = 0
    apis_count: int = 0
    open_bugs_count: int = 0
    active_tasks_count: int = 0

    class Config:
        from_attributes = True


# ---------------------------------------------------------------------------
# Module Schemas
# ---------------------------------------------------------------------------
class ModuleBase(BaseModel):
    project_id: int
    name: str
    description: Optional[str] = None
    status: str = "active"
    progress: int = Field(default=0, ge=0, le=100)


class ModuleCreate(ModuleBase):
    pass


class ModuleUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None
    progress: Optional[int] = Field(default=None, ge=0, le=100)


class ModuleResponse(ModuleBase):
    id: int
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    apis_count: int = 0
    bugs_count: int = 0
    tasks_count: int = 0

    class Config:
        from_attributes = True


# ---------------------------------------------------------------------------
# API Catalog Schemas
# ---------------------------------------------------------------------------
class ApiBase(BaseModel):
    project_id: int
    module_id: Optional[int] = None
    name: str
    endpoint: str
    method: str = "GET"
    status: str = "active"
    version: str = "v1"
    description: Optional[str] = None
    health_status: str = "healthy"


class ApiCreate(ApiBase):
    pass


class ApiUpdate(BaseModel):
    name: Optional[str] = None
    endpoint: Optional[str] = None
    method: Optional[str] = None
    status: Optional[str] = None
    version: Optional[str] = None
    description: Optional[str] = None
    health_status: Optional[str] = None


class ApiResponse(ApiBase):
    id: int
    last_tested_at: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# ---------------------------------------------------------------------------
# Task Schemas
# ---------------------------------------------------------------------------
class TaskCommentCreate(BaseModel):
    message: str


class TaskCommentResponse(BaseModel):
    id: int
    task_id: int
    author_id: int
    author_name: str
    author_role: str
    message: str
    created_at: datetime

    class Config:
        from_attributes = True


class TaskCreate(BaseModel):
    project_id: int
    module_id: Optional[int] = None
    title: str
    description: Optional[str] = None
    priority: str = "medium"
    status: str = "todo"
    assigned_developer_id: Optional[int] = None
    assigned_qa_id: Optional[int] = None
    due_date: Optional[datetime] = None


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    priority: Optional[str] = None
    status: Optional[str] = None
    assigned_developer_id: Optional[int] = None
    assigned_qa_id: Optional[int] = None
    due_date: Optional[datetime] = None


class TaskResponse(BaseModel):
    id: int
    project_id: int
    project_name: Optional[str] = None
    module_id: Optional[int] = None
    module_name: Optional[str] = None
    title: str
    description: Optional[str] = None
    priority: str
    status: str
    assigned_developer_id: Optional[int] = None
    developer_name: Optional[str] = None
    assigned_qa_id: Optional[int] = None
    qa_name: Optional[str] = None
    due_date: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    created_by_id: Optional[int] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    comments: List[TaskCommentResponse] = []

    class Config:
        from_attributes = True


# ---------------------------------------------------------------------------
# Bug Comments & Activity History
# ---------------------------------------------------------------------------
class BugCommentCreate(BaseModel):
    message: str
    attachment_url: Optional[str] = None


class BugCommentResponse(BaseModel):
    id: int
    bug_id: int
    author_id: int
    author_name: str
    author_role: str
    message: str
    attachment_url: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


class BugActivityHistoryResponse(BaseModel):
    id: int
    bug_id: int
    actor_id: int
    actor_name: str
    actor_role: str
    action: str
    old_value: Optional[str] = None
    new_value: Optional[str] = None
    notes: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


# ---------------------------------------------------------------------------
# Bug Schemas & State Machine
# ---------------------------------------------------------------------------
class BugCreate(BaseModel):
    project_id: int
    module_id: Optional[int] = None
    api_id: Optional[int] = None
    title: str
    description: Optional[str] = None
    severity: str = "medium"  # low, medium, high, critical
    priority: str = "medium"  # low, medium, high, critical
    environment: str = "development"  # development, staging, production
    browser: Optional[str] = None
    os: Optional[str] = None
    assigned_developer_id: Optional[int] = None
    assigned_qa_id: Optional[int] = None
    steps_to_reproduce: Optional[str] = None
    expected_result: Optional[str] = None
    actual_result: Optional[str] = None
    api_endpoint: Optional[str] = None
    request_payload_reference: Optional[str] = None
    response_reference: Optional[str] = None
    attachment_urls: Optional[List[str]] = None


class BugUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    severity: Optional[str] = None
    priority: Optional[str] = None
    environment: Optional[str] = None
    browser: Optional[str] = None
    os: Optional[str] = None
    steps_to_reproduce: Optional[str] = None
    expected_result: Optional[str] = None
    actual_result: Optional[str] = None
    technical_notes: Optional[str] = None
    developer_notes: Optional[str] = None
    qa_notes: Optional[str] = None
    api_endpoint: Optional[str] = None
    request_payload_reference: Optional[str] = None
    response_reference: Optional[str] = None
    commit_reference: Optional[str] = None
    release_version: Optional[str] = None
    attachment_urls: Optional[List[str]] = None


class BugTransitionRequest(BaseModel):
    new_status: str
    notes: Optional[str] = None
    reassign_to_id: Optional[int] = None
    commit_reference: Optional[str] = None
    release_version: Optional[str] = None


class BugAssignRequest(BaseModel):
    developer_id: Optional[int] = None
    qa_id: Optional[int] = None
    notes: Optional[str] = None


class BugResponse(BaseModel):
    id: int
    bug_code: str
    project_id: int
    project_name: Optional[str] = None
    module_id: Optional[int] = None
    module_name: Optional[str] = None
    api_id: Optional[int] = None
    api_name: Optional[str] = None
    title: str
    description: Optional[str] = None
    severity: str
    priority: str
    status: str
    environment: str
    browser: Optional[str] = None
    os: Optional[str] = None
    reported_by_id: int
    reporter_name: Optional[str] = None
    assigned_developer_id: Optional[int] = None
    developer_name: Optional[str] = None
    assigned_qa_id: Optional[int] = None
    qa_name: Optional[str] = None
    steps_to_reproduce: Optional[str] = None
    expected_result: Optional[str] = None
    actual_result: Optional[str] = None
    technical_notes: Optional[str] = None
    developer_notes: Optional[str] = None
    qa_notes: Optional[str] = None
    api_endpoint: Optional[str] = None
    request_payload_reference: Optional[str] = None
    response_reference: Optional[str] = None
    commit_reference: Optional[str] = None
    release_version: Optional[str] = None
    attachment_urls: Optional[List[str]] = None
    reopened_count: int = 0
    fixed_at: Optional[datetime] = None
    verified_at: Optional[datetime] = None
    closed_at: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    comments: List[BugCommentResponse] = []
    activity_history: List[BugActivityHistoryResponse] = []

    class Config:
        from_attributes = True


class BugListResponse(BaseModel):
    items: List[BugResponse]
    total: int
    page: int
    page_size: int
    total_pages: int


# ---------------------------------------------------------------------------
# Notifications
# ---------------------------------------------------------------------------
class NotificationResponse(BaseModel):
    id: int
    recipient_id: int
    sender_id: Optional[int] = None
    sender_name: Optional[str] = None
    title: str
    message: str
    notification_type: str
    reference_type: Optional[str] = None
    reference_id: Optional[int] = None
    is_read: bool
    created_at: datetime

    class Config:
        from_attributes = True


# ---------------------------------------------------------------------------
# Deployments
# ---------------------------------------------------------------------------
class DeploymentCreate(BaseModel):
    project_id: int
    environment: str  # DEVELOPMENT, STAGING, PRODUCTION
    version: str
    commit_hash: Optional[str] = None
    changelog: Optional[str] = None


class DeploymentResponse(BaseModel):
    id: int
    project_id: int
    project_name: Optional[str] = None
    environment: str
    version: str
    commit_hash: Optional[str] = None
    status: str
    deployed_by_id: int
    deployer_name: Optional[str] = None
    changelog: Optional[str] = None
    deployed_at: datetime

    class Config:
        from_attributes = True


# ---------------------------------------------------------------------------
# Audit Logs
# ---------------------------------------------------------------------------
class AuditLogResponse(BaseModel):
    id: int
    actor_id: Optional[int] = None
    actor_name: Optional[str] = None
    actor_role: Optional[str] = None
    action: str
    resource_type: str
    resource_id: Optional[str] = None
    details: Optional[str] = None
    ip_address: Optional[str] = None
    status: str
    created_at: datetime

    class Config:
        from_attributes = True


# ---------------------------------------------------------------------------
# Dashboard Schemas
# ---------------------------------------------------------------------------
class GlobalDashboardStats(BaseModel):
    projects_count: int
    apis_count: int
    open_bugs_count: int
    developers_count: int
    qa_count: int
    development_progress: Dict[str, int]  # Backend, Frontend, Mobile, API
    system_status: Dict[str, Dict[str, Any]]  # api_server, database, auth, payment, notification
    api_performance: Dict[str, Any]  # total_requests, avg_latency_ms, error_rate_percent, uptime_percent
    bug_summary: Dict[str, int]  # critical, high, medium, low
    recent_activities: List[BugActivityHistoryResponse]
    deployment_summary: List[DeploymentResponse]


class DeveloperDashboardStats(BaseModel):
    my_projects_count: int
    my_modules_count: int
    my_tasks_count: int
    my_open_bugs_count: int
    critical_bugs_count: int
    bugs_awaiting_action_count: int
    bugs_returned_by_qa_count: int
    completed_tasks_count: int
    workload_percent: int
    my_bugs: List[BugResponse]
    my_tasks: List[TaskResponse]
    recent_activity: List[BugActivityHistoryResponse]


class QADashboardStats(BaseModel):
    new_bugs_count: int
    assigned_to_dev_count: int
    bugs_awaiting_qa_count: int
    under_qa_testing_count: int
    reopened_bugs_count: int
    verified_bugs_count: int
    critical_bugs_count: int
    high_priority_bugs_count: int
    average_resolution_hours: float
    reopen_rate_percent: float
    developer_wise_bugs: List[Dict[str, Any]]
    module_wise_bugs: List[Dict[str, Any]]
    awaiting_verification_bugs: List[BugResponse]


# ---------------------------------------------------------------------------
# Safe Diagnostics & Analytics Schemas
# ---------------------------------------------------------------------------
class DatabaseHealthStats(BaseModel):
    status: str
    dialect: str
    pool_size: int
    pool_status: str
    tables_overview: List[Dict[str, Any]]  # table_name, row_count, primary_key
    migrations_status: str


class SecurityAuditStats(BaseModel):
    auth_health: str
    total_logins_24h: int
    failed_logins_24h: int
    active_sessions_count: int
    api_error_rate_percent: float
    suspicious_indicators_count: int
    recent_security_events: List[Dict[str, Any]]


class AnalyticsTrends(BaseModel):
    timeframe: str  # today, 7d, 30d, custom
    bug_trend: List[Dict[str, Any]]  # date, created, fixed, verified, rejected
    task_completion: List[Dict[str, Any]]
    developer_workload: List[Dict[str, Any]]
    qa_workload: List[Dict[str, Any]]
    module_health: List[Dict[str, Any]]


class ProjectWorkspaceResponse(BaseModel):
    project: ProjectResponse
    members: List[ProjectMemberResponse] = []
    modules: List[ModuleResponse] = []
    apis: List[ApiResponse] = []
    bugs: List[BugResponse] = []
    tasks: List[TaskResponse] = []

