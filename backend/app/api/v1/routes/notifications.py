from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_principal
from app.core.security import Principal
from app.db.session import get_db
from app.modules.notifications.repository import NotificationRepository
from app.modules.notifications.schemas import NotificationMarkReadResponse, NotificationRead
from app.modules.notifications.service import NotificationService
from app.modules.users.repository import UserRepository

router = APIRouter()


def _service(db: Session) -> NotificationService:
    return NotificationService(NotificationRepository(db))


def _recipient_user_id(principal: Principal, db: Session) -> UUID:
    user = UserRepository(db).get_by_supabase_user_id(principal.user_id)
    if user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User profile not found")
    return user.id


@router.get("", response_model=list[NotificationRead])
def list_notifications(
    unread_only: bool = Query(default=False),
    limit: int = Query(default=50, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    recipient_user_id = _recipient_user_id(principal, db)
    return _service(db).list_notifications(
        recipient_user_id,
        limit=limit,
        offset=offset,
        unread_only=unread_only,
    )


@router.get("/unread-count")
def unread_count(
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    recipient_user_id = _recipient_user_id(principal, db)
    return {"count": _service(db).unread_count(recipient_user_id)}


@router.post("/{notification_id}/mark-read", response_model=NotificationMarkReadResponse)
def mark_read(
    notification_id: UUID,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    recipient_user_id = _recipient_user_id(principal, db)
    return _service(db).mark_read(notification_id, recipient_user_id)


@router.post("/mark-all-read")
def mark_all_read(
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    recipient_user_id = _recipient_user_id(principal, db)
    count = _service(db).mark_all_read(recipient_user_id)
    return {"updated": count}
