from uuid import UUID

from sqlalchemy.orm import Session

from app.modules.audit_logs.models import AuditLog


def add_audit_log(
    db: Session,
    *,
    action: str,
    entity_type: str,
    actor_user_id: UUID | None = None,
    entity_id: UUID | None = None,
    court_id: UUID | None = None,
    event_id: UUID | None = None,
    match_id: UUID | None = None,
    details: dict | None = None,
) -> None:
    db.add(
        AuditLog(
            actor_user_id=actor_user_id,
            court_id=court_id,
            event_id=event_id,
            match_id=match_id,
            action=action,
            entity_type=entity_type,
            entity_id=entity_id,
            details_json=details,
        )
    )
