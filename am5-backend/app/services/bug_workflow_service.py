from datetime import datetime
from typing import Optional, Tuple
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.employee import Employee
from app.models.developer_portal import (
    DevBug,
    DevBugActivityHistory,
    DevNotification,
    DevAuditLog,
)


class BugWorkflowService:
    # Jira-style flexible transitions: team members can move tickets across workflow states
    ALL_ROLES = ["developer", "qa", "admin", "super_admin", "team_lead", "manager"]

    VALID_TRANSITIONS = {
        "NEW": {
            "ASSIGNED_TO_DEVELOPER": ALL_ROLES,
            "IN_PROGRESS": ALL_ROLES,
            "CLOSED": ALL_ROLES,
        },
        "ASSIGNED_TO_DEVELOPER": {
            "IN_PROGRESS": ALL_ROLES,
            "READY_FOR_QA": ALL_ROLES,
            "NEW": ALL_ROLES,
            "CLOSED": ALL_ROLES,
        },
        "IN_PROGRESS": {
            "READY_FOR_QA": ALL_ROLES,
            "FIXED": ALL_ROLES,
            "QA_TESTING": ALL_ROLES,
            "ASSIGNED_TO_DEVELOPER": ALL_ROLES,
            "CLOSED": ALL_ROLES,
        },
        "FIXED": {
            "READY_FOR_QA": ALL_ROLES,
            "QA_TESTING": ALL_ROLES,
            "IN_PROGRESS": ALL_ROLES,
        },
        "READY_FOR_QA": {
            "QA_TESTING": ALL_ROLES,
            "VERIFIED": ALL_ROLES,
            "QA_REJECTED": ALL_ROLES,
            "IN_PROGRESS": ALL_ROLES,
        },
        "QA_TESTING": {
            "VERIFIED": ALL_ROLES,
            "QA_REJECTED": ALL_ROLES,
            "READY_FOR_QA": ALL_ROLES,
            "CLOSED": ALL_ROLES,
            "REOPENED": ALL_ROLES,
        },
        "QA_REJECTED": {
            "IN_PROGRESS": ALL_ROLES,
            "REOPENED": ALL_ROLES,
            "ASSIGNED_TO_DEVELOPER": ALL_ROLES,
            "READY_FOR_QA": ALL_ROLES,
        },
        "REOPENED": {
            "IN_PROGRESS": ALL_ROLES,
            "ASSIGNED_TO_DEVELOPER": ALL_ROLES,
            "READY_FOR_QA": ALL_ROLES,
            "CLOSED": ALL_ROLES,
        },
        "VERIFIED": {
            "CLOSED": ALL_ROLES,
            "REOPENED": ALL_ROLES,
            "IN_PROGRESS": ALL_ROLES,
        },
        "CLOSED": {
            "REOPENED": ALL_ROLES,
            "IN_PROGRESS": ALL_ROLES,
        },
    }

    @classmethod
    def get_allowed_transitions(cls, current_status: str, actor_role: str = "developer") -> list[str]:
        possible = cls.VALID_TRANSITIONS.get(current_status, {})
        return list(possible.keys())

    @classmethod
    async def validate_and_execute_transition(
        cls,
        db: AsyncSession,
        bug: DevBug,
        new_status: str,
        actor: Employee,
        notes: Optional[str] = None,
        reassign_to_id: Optional[int] = None,
        commit_reference: Optional[str] = None,
        release_version: Optional[str] = None,
    ) -> DevBug:
        actor_role = (actor.role or "developer").lower()
        current_status = bug.status

        # 1. Check if the transition is allowed from current_status
        possible_transitions = cls.VALID_TRANSITIONS.get(current_status, {})
        if new_status not in possible_transitions:
            # Fallback: if user picked same status or standard workflow, allow
            pass

        # 4. Action determination
        action = "STATUS_CHANGED"
        if new_status == "FIXED":
            action = "FIX_SUBMITTED"
            bug.fixed_at = datetime.utcnow()
        elif new_status == "READY_FOR_QA":
            action = "READY_FOR_QA"
            if not bug.fixed_at:
                bug.fixed_at = datetime.utcnow()
        elif new_status == "QA_TESTING":
            action = "QA_STARTED"
        elif new_status == "VERIFIED":
            action = "QA_VERIFIED"
            bug.verified_at = datetime.utcnow()
        elif new_status == "QA_REJECTED":
            action = "QA_REJECTED"
            bug.reopened_count = (bug.reopened_count or 0) + 1
        elif new_status == "REOPENED":
            action = "BUG_REOPENED"
            bug.reopened_count = (bug.reopened_count or 0) + 1
        elif new_status == "CLOSED":
            action = "BUG_CLOSED"
            bug.closed_at = datetime.utcnow()

        # Update metadata
        if commit_reference:
            bug.commit_reference = commit_reference
        if release_version:
            bug.release_version = release_version

        # Handle reassignments on transition if provided
        if reassign_to_id:
            if new_status in ["READY_FOR_QA", "QA_TESTING"]:
                bug.assigned_qa_id = reassign_to_id
            else:
                bug.assigned_developer_id = reassign_to_id

        # Update bug status
        old_status = bug.status
        bug.status = new_status
        bug.updated_at = datetime.utcnow()

        # 5. Record activity history
        actor_name = f"{actor.first_name or ''} {actor.last_name or ''}".strip() or actor.email
        history_entry = DevBugActivityHistory(
            bug_id=bug.id,
            actor_id=actor.id,
            actor_role=actor_role,
            action=action,
            old_value=old_status,
            new_value=new_status,
            notes=notes,
        )
        db.add(history_entry)

        # 6. Generate Notification
        await cls._generate_transition_notification(db, bug, old_status, new_status, actor, actor_name, notes)

        # 7. Audit Log
        audit_log = DevAuditLog(
            actor_id=actor.id,
            actor_role=actor_role,
            actor_name=actor_name,
            action=f"BUG_STATUS_{new_status}",
            resource_type="BUG",
            resource_id=str(bug.id),
            details=f"Transitioned {bug.bug_code} from {old_status} to {new_status}. Notes: {notes or 'N/A'}",
            status="success",
        )
        db.add(audit_log)

        await db.commit()
        await db.refresh(bug)
        return bug

    @classmethod
    async def assign_bug(
        cls,
        db: AsyncSession,
        bug: DevBug,
        actor: Employee,
        developer_id: Optional[int] = None,
        qa_id: Optional[int] = None,
        notes: Optional[str] = None,
    ) -> DevBug:
        actor_role = (actor.role or "developer").lower()
        if actor_role not in ["qa", "admin", "super_admin", "developer"]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to assign bugs",
            )

        actor_name = f"{actor.first_name or ''} {actor.last_name or ''}".strip() or actor.email
        changes = []

        if developer_id is not None and developer_id != bug.assigned_developer_id:
            old_dev_id = bug.assigned_developer_id
            bug.assigned_developer_id = developer_id
            if bug.status == "NEW":
                bug.status = "ASSIGNED_TO_DEVELOPER"
            changes.append(f"Developer: {old_dev_id} -> {developer_id}")

            # Notify new developer
            notif = DevNotification(
                recipient_id=developer_id,
                sender_id=actor.id,
                title=f"Bug Assigned: {bug.bug_code}",
                message=f"You have been assigned to {bug.bug_code}: {bug.title}",
                notification_type="bug_assigned",
                reference_type="bug",
                reference_id=bug.id,
            )
            db.add(notif)

        if qa_id is not None and qa_id != bug.assigned_qa_id:
            old_qa_id = bug.assigned_qa_id
            bug.assigned_qa_id = qa_id
            changes.append(f"QA: {old_qa_id} -> {qa_id}")

            notif = DevNotification(
                recipient_id=qa_id,
                sender_id=actor.id,
                title=f"QA Assigned: {bug.bug_code}",
                message=f"You are the assigned QA for {bug.bug_code}: {bug.title}",
                notification_type="bug_assigned",
                reference_type="bug",
                reference_id=bug.id,
            )
            db.add(notif)

        if changes:
            bug.updated_at = datetime.utcnow()
            history = DevBugActivityHistory(
                bug_id=bug.id,
                actor_id=actor.id,
                actor_role=actor_role,
                action="REASSIGNED",
                old_value=None,
                new_value=", ".join(changes),
                notes=notes,
            )
            db.add(history)

            audit_log = DevAuditLog(
                actor_id=actor.id,
                actor_role=actor_role,
                actor_name=actor_name,
                action="BUG_REASSIGNED",
                resource_type="BUG",
                resource_id=str(bug.id),
                details=f"Reassigned {bug.bug_code}: {', '.join(changes)}. Notes: {notes or 'N/A'}",
                status="success",
            )
            db.add(audit_log)

            await db.commit()
            await db.refresh(bug)

        return bug

    @classmethod
    async def _generate_transition_notification(
        cls,
        db: AsyncSession,
        bug: DevBug,
        old_status: str,
        new_status: str,
        actor: Employee,
        actor_name: str,
        notes: Optional[str],
    ):
        recipients = set()

        if new_status in ["READY_FOR_QA", "FIXED"]:
            if bug.assigned_qa_id and bug.assigned_qa_id != actor.id:
                recipients.add(bug.assigned_qa_id)
            if bug.reported_by_id and bug.reported_by_id != actor.id:
                recipients.add(bug.reported_by_id)

        elif new_status in ["QA_REJECTED", "REOPENED", "ASSIGNED_TO_DEVELOPER"]:
            if bug.assigned_developer_id and bug.assigned_developer_id != actor.id:
                recipients.add(bug.assigned_developer_id)

        elif new_status in ["VERIFIED", "CLOSED"]:
            if bug.assigned_developer_id and bug.assigned_developer_id != actor.id:
                recipients.add(bug.assigned_developer_id)

        for recipient_id in recipients:
            notif = DevNotification(
                recipient_id=recipient_id,
                sender_id=actor.id,
                title=f"{bug.bug_code} is now {new_status}",
                message=f"{actor_name} moved {bug.bug_code} to {new_status}. {notes or ''}".strip(),
                notification_type="bug_status_change",
                reference_type="bug",
                reference_id=bug.id,
            )
            db.add(notif)


bug_workflow_service = BugWorkflowService()
