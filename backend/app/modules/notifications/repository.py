from __future__ import annotations

from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy.orm import Session

from app.modules.notifications.models import Notification


class NotificationRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def list_for_user(
        self,
        recipient_user_id: UUID,
        *,
        limit: int = 50,
        offset: int = 0,
        unread_only: bool = False,
    ) -> list[Notification]:
        query = self.db.query(Notification).filter(
            Notification.deleted_at.is_(None),
            Notification.recipient_user_id == recipient_user_id,
        )
        if unread_only:
            query = query.filter(Notification.read_at.is_(None))
        return query.order_by(Notification.created_at.desc()).offset(offset).limit(limit).all()

    def count_unread_for_user(self, recipient_user_id: UUID) -> int:
        return (
            self.db.query(Notification)
            .filter(
                Notification.deleted_at.is_(None),
                Notification.recipient_user_id == recipient_user_id,
                Notification.read_at.is_(None),
            )
            .count()
        )

    def get_for_user(self, notification_id: UUID, recipient_user_id: UUID) -> Notification | None:
        return (
            self.db.query(Notification)
            .filter(
                Notification.deleted_at.is_(None),
                Notification.id == notification_id,
                Notification.recipient_user_id == recipient_user_id,
            )
            .one_or_none()
        )

    def create(self, notification: Notification) -> Notification:
        self.db.add(notification)
        self.db.commit()
        self.db.refresh(notification)
        return notification

    def mark_read(self, notification: Notification) -> Notification:
        self.db.add(notification)
        self.db.commit()
        self.db.refresh(notification)
        return notification

    def mark_all_read(self, recipient_user_id: UUID) -> int:
        notifications = self.list_for_user(recipient_user_id, unread_only=True, limit=10_000)
        now = datetime.now(UTC)
        for notification in notifications:
            if notification.read_at is None:
                notification.read_at = now
                self.db.add(notification)
        self.db.commit()
        return len(notifications)
