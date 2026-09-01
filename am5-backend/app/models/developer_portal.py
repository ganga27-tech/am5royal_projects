from sqlalchemy import (
    Column,
    String,
    Integer,
    BigInteger,
    ForeignKey,
    DateTime,
    Text,
    Boolean,
    JSON,
)
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.base_class import Base


class DevProject(Base):
    __tablename__ = "dev_projects"

    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(150), nullable=False)
    slug = Column(String(100), unique=True, index=True, nullable=False)
    description = Column(Text, nullable=True)
    status = Column(String(50), default="active", nullable=False)  # active, in_progress, maintenance, completed
    progress = Column(Integer, default=0, nullable=False)  # 0 to 100
    repository_url = Column(String(255), nullable=True)
    created_by_id = Column(BigInteger, ForeignKey("employees.id"), nullable=True)
    project_head_id = Column(BigInteger, ForeignKey("employees.id", ondelete="SET NULL"), nullable=True, index=True)

    # Relationships
    project_head = relationship("Employee", foreign_keys=[project_head_id])
    members = relationship("DevProjectMember", back_populates="project", cascade="all, delete-orphan")
    modules = relationship("DevProjectModule", back_populates="project", cascade="all, delete-orphan")
    apis = relationship("DevProjectApi", back_populates="project", cascade="all, delete-orphan")
    tasks = relationship("DevTask", back_populates="project", cascade="all, delete-orphan")
    bugs = relationship("DevBug", back_populates="project", cascade="all, delete-orphan")
    deployments = relationship("DevDeployment", back_populates="project", cascade="all, delete-orphan")


class DevProjectMember(Base):
    __tablename__ = "dev_project_members"

    id = Column(BigInteger, primary_key=True, index=True)
    project_id = Column(BigInteger, ForeignKey("dev_projects.id", ondelete="CASCADE"), nullable=False, index=True)
    employee_id = Column(BigInteger, ForeignKey("employees.id", ondelete="CASCADE"), nullable=False, index=True)
    project_role = Column(String(50), default="developer", nullable=False)  # developer, qa, lead, viewer
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    project = relationship("DevProject", back_populates="members")
    employee = relationship("Employee", foreign_keys=[employee_id])


class DevProjectModule(Base):
    __tablename__ = "dev_project_modules"

    id = Column(BigInteger, primary_key=True, index=True)
    project_id = Column(BigInteger, ForeignKey("dev_projects.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String(150), nullable=False)
    description = Column(Text, nullable=True)
    status = Column(String(50), default="active", nullable=False)  # active, in_progress, under_review, completed
    progress = Column(Integer, default=0, nullable=False)

    project = relationship("DevProject", back_populates="modules")
    apis = relationship("DevProjectApi", back_populates="module")
    tasks = relationship("DevTask", back_populates="module")
    bugs = relationship("DevBug", back_populates="module")


class DevProjectApi(Base):
    __tablename__ = "dev_project_apis"

    id = Column(BigInteger, primary_key=True, index=True)
    project_id = Column(BigInteger, ForeignKey("dev_projects.id", ondelete="CASCADE"), nullable=False, index=True)
    module_id = Column(BigInteger, ForeignKey("dev_project_modules.id", ondelete="SET NULL"), nullable=True, index=True)
    name = Column(String(150), nullable=False)
    endpoint = Column(String(255), nullable=False)
    method = Column(String(10), default="GET", nullable=False)  # GET, POST, PUT, DELETE, PATCH
    status = Column(String(50), default="active", nullable=False)  # active, in_development, beta, deprecated
    version = Column(String(20), default="v1", nullable=False)
    description = Column(Text, nullable=True)
    health_status = Column(String(50), default="healthy", nullable=False)  # healthy, degraded, down
    last_tested_at = Column(DateTime(timezone=True), nullable=True)

    project = relationship("DevProject", back_populates="apis")
    module = relationship("DevProjectModule", back_populates="apis")


class DevTask(Base):
    __tablename__ = "dev_tasks"

    id = Column(BigInteger, primary_key=True, index=True)
    project_id = Column(BigInteger, ForeignKey("dev_projects.id", ondelete="CASCADE"), nullable=False, index=True)
    module_id = Column(BigInteger, ForeignKey("dev_project_modules.id", ondelete="SET NULL"), nullable=True, index=True)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    priority = Column(String(50), default="medium", nullable=False)  # low, medium, high, critical
    status = Column(String(50), default="todo", nullable=False)  # todo, in_progress, blocked, completed
    assigned_developer_id = Column(BigInteger, ForeignKey("employees.id", ondelete="SET NULL"), nullable=True, index=True)
    assigned_qa_id = Column(BigInteger, ForeignKey("employees.id", ondelete="SET NULL"), nullable=True, index=True)
    due_date = Column(DateTime(timezone=True), nullable=True)
    completed_at = Column(DateTime(timezone=True), nullable=True)
    created_by_id = Column(BigInteger, ForeignKey("employees.id"), nullable=True)

    project = relationship("DevProject", back_populates="tasks")
    module = relationship("DevProjectModule", back_populates="tasks")
    comments = relationship("DevTaskComment", back_populates="task", cascade="all, delete-orphan")


class DevTaskComment(Base):
    __tablename__ = "dev_task_comments"

    id = Column(BigInteger, primary_key=True, index=True)
    task_id = Column(BigInteger, ForeignKey("dev_tasks.id", ondelete="CASCADE"), nullable=False, index=True)
    author_id = Column(BigInteger, ForeignKey("employees.id"), nullable=False)
    message = Column(Text, nullable=False)

    task = relationship("DevTask", back_populates="comments")


class DevBug(Base):
    __tablename__ = "dev_bugs"

    id = Column(BigInteger, primary_key=True, index=True)
    bug_code = Column(String(50), unique=True, index=True, nullable=False)  # e.g., BUG-1001
    project_id = Column(BigInteger, ForeignKey("dev_projects.id", ondelete="CASCADE"), nullable=False, index=True)
    module_id = Column(BigInteger, ForeignKey("dev_project_modules.id", ondelete="SET NULL"), nullable=True, index=True)
    api_id = Column(BigInteger, ForeignKey("dev_project_apis.id", ondelete="SET NULL"), nullable=True)

    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    severity = Column(String(50), default="medium", nullable=False)  # low, medium, high, critical
    priority = Column(String(50), default="medium", nullable=False)  # low, medium, high, critical
    status = Column(String(50), default="NEW", nullable=False, index=True)
    # State Machine: NEW, ASSIGNED_TO_DEVELOPER, IN_PROGRESS, FIXED, READY_FOR_QA, QA_TESTING, VERIFIED, QA_REJECTED, REOPENED, CLOSED

    environment = Column(String(50), default="development", nullable=False)  # development, staging, production
    browser = Column(String(100), nullable=True)
    os = Column(String(100), nullable=True)

    reported_by_id = Column(BigInteger, ForeignKey("employees.id"), nullable=False, index=True)
    assigned_developer_id = Column(BigInteger, ForeignKey("employees.id", ondelete="SET NULL"), nullable=True, index=True)
    assigned_qa_id = Column(BigInteger, ForeignKey("employees.id", ondelete="SET NULL"), nullable=True, index=True)

    steps_to_reproduce = Column(Text, nullable=True)
    expected_result = Column(Text, nullable=True)
    actual_result = Column(Text, nullable=True)
    technical_notes = Column(Text, nullable=True)
    developer_notes = Column(Text, nullable=True)
    qa_notes = Column(Text, nullable=True)

    api_endpoint = Column(String(255), nullable=True)
    request_payload_reference = Column(Text, nullable=True)
    response_reference = Column(Text, nullable=True)
    commit_reference = Column(String(100), nullable=True)
    release_version = Column(String(50), nullable=True)
    attachment_urls = Column(JSON, nullable=True)  # List of URLs/paths

    reopened_count = Column(Integer, default=0, nullable=False)
    fixed_at = Column(DateTime(timezone=True), nullable=True)
    verified_at = Column(DateTime(timezone=True), nullable=True)
    closed_at = Column(DateTime(timezone=True), nullable=True)

    project = relationship("DevProject", back_populates="bugs")
    module = relationship("DevProjectModule", back_populates="bugs")
    comments = relationship("DevBugComment", back_populates="bug", cascade="all, delete-orphan", order_by="DevBugComment.created_at.asc()")
    activity_history = relationship("DevBugActivityHistory", back_populates="bug", cascade="all, delete-orphan", order_by="DevBugActivityHistory.created_at.desc()")


class DevBugComment(Base):
    __tablename__ = "dev_bug_comments"

    id = Column(BigInteger, primary_key=True, index=True)
    bug_id = Column(BigInteger, ForeignKey("dev_bugs.id", ondelete="CASCADE"), nullable=False, index=True)
    author_id = Column(BigInteger, ForeignKey("employees.id"), nullable=False)
    author_role = Column(String(50), nullable=False)  # developer, qa, admin
    message = Column(Text, nullable=False)
    attachment_url = Column(String(500), nullable=True)

    bug = relationship("DevBug", back_populates="comments")


class DevBugActivityHistory(Base):
    __tablename__ = "dev_bug_activity_history"

    id = Column(BigInteger, primary_key=True, index=True)
    bug_id = Column(BigInteger, ForeignKey("dev_bugs.id", ondelete="CASCADE"), nullable=False, index=True)
    actor_id = Column(BigInteger, ForeignKey("employees.id"), nullable=False)
    actor_role = Column(String(50), nullable=False)
    action = Column(String(100), nullable=False)
    # Actions: BUG_CREATED, BUG_ASSIGNED, STATUS_CHANGED, COMMENT_ADDED, REASSIGNED, FIX_SUBMITTED, QA_STARTED, QA_REJECTED, QA_VERIFIED, BUG_REOPENED, BUG_CLOSED
    old_value = Column(String(255), nullable=True)
    new_value = Column(String(255), nullable=True)
    notes = Column(Text, nullable=True)

    bug = relationship("DevBug", back_populates="activity_history")


class DevNotification(Base):
    __tablename__ = "dev_notifications"

    id = Column(BigInteger, primary_key=True, index=True)
    recipient_id = Column(BigInteger, ForeignKey("employees.id", ondelete="CASCADE"), nullable=False, index=True)
    sender_id = Column(BigInteger, ForeignKey("employees.id", ondelete="SET NULL"), nullable=True)
    title = Column(String(255), nullable=False)
    message = Column(Text, nullable=False)
    notification_type = Column(String(100), nullable=False)  # bug_assigned, bug_status_change, bug_comment, task_assigned, etc.
    reference_type = Column(String(50), nullable=True)  # bug, task, project
    reference_id = Column(BigInteger, nullable=True)
    is_read = Column(Boolean, default=False, nullable=False, index=True)


class DevDeployment(Base):
    __tablename__ = "dev_deployments"

    id = Column(BigInteger, primary_key=True, index=True)
    project_id = Column(BigInteger, ForeignKey("dev_projects.id", ondelete="CASCADE"), nullable=False, index=True)
    environment = Column(String(50), nullable=False)  # DEVELOPMENT, STAGING, PRODUCTION
    version = Column(String(50), nullable=False)
    commit_hash = Column(String(100), nullable=True)
    status = Column(String(50), default="pending", nullable=False)  # pending, in_progress, success, failed, rolled_back
    deployed_by_id = Column(BigInteger, ForeignKey("employees.id"), nullable=False)
    changelog = Column(Text, nullable=True)
    deployed_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    project = relationship("DevProject", back_populates="deployments")


class DevAuditLog(Base):
    __tablename__ = "dev_audit_logs"

    id = Column(BigInteger, primary_key=True, index=True)
    actor_id = Column(BigInteger, ForeignKey("employees.id", ondelete="SET NULL"), nullable=True, index=True)
    actor_role = Column(String(50), nullable=True)
    actor_name = Column(String(150), nullable=True)
    action = Column(String(100), nullable=False, index=True)
    resource_type = Column(String(100), nullable=False, index=True)
    resource_id = Column(String(100), nullable=True)
    details = Column(Text, nullable=True)
    ip_address = Column(String(50), nullable=True)
    status = Column(String(50), default="success", nullable=False)
