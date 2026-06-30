from __future__ import annotations

from datetime import UTC, datetime
from uuid import UUID

from fastapi import HTTPException, status

from app.modules.notifications.models import Notification
from app.modules.notifications.repository import NotificationRepository
from app.modules.notifications.schemas import NotificationCreate


class NotificationService:
    def __init__(self, repository: NotificationRepository) -> None:
        self.repository = repository

    def list_notifications(
        self,
        recipient_user_id: UUID,
        *,
        limit: int,
        offset: int,
        unread_only: bool = False,
    ) -> list[Notification]:
        return self.repository.list_for_user(
            recipient_user_id,
            limit=limit,
            offset=offset,
            unread_only=unread_only,
        )

    def unread_count(self, recipient_user_id: UUID) -> int:
        return self.repository.count_unread_for_user(recipient_user_id)

    def create_notification(self, payload: NotificationCreate) -> Notification:
        notification = Notification(
            recipient_user_id=payload.recipient_user_id,
            actor_user_id=payload.actor_user_id,
            notification_type=payload.notification_type,
            category=payload.category,
            title=payload.title,
            body=payload.body,
            action_url=payload.action_url,
            related_entity_type=payload.related_entity_type,
            related_entity_id=payload.related_entity_id,
            metadata_json=payload.metadata_json,
        )
        return self.repository.create(notification)

    def mark_read(self, notification_id: UUID, recipient_user_id: UUID) -> Notification:
        notification = self.repository.get_for_user(notification_id, recipient_user_id)
        if notification is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Notification not found")
        if notification.read_at is None:
            notification.read_at = datetime.now(UTC)
            notification = self.repository.mark_read(notification)
        return notification

    def mark_all_read(self, recipient_user_id: UUID) -> int:
        return self.repository.mark_all_read(recipient_user_id)

    def notify_rating_update(
        self,
        *,
        recipient_user_id: UUID,
        old_rating: float,
        new_rating: float,
        actor_user_id: UUID | None = None,
        related_entity_id: UUID | None = None,
        action_url: str | None = None,
    ) -> Notification:
        delta = new_rating - old_rating
        direction = "up" if delta >= 0 else "down"
        title = "Your rating changed"
        body = f"Your rating moved {direction} by {abs(delta):.2f} to {new_rating:.2f}."
        return self.create_notification(
            NotificationCreate(
                recipient_user_id=recipient_user_id,
                notification_type="rating_update",
                category="rating",
                title=title,
                body=body,
                action_url=action_url,
                actor_user_id=actor_user_id,
                related_entity_type="rating_history",
                related_entity_id=related_entity_id,
                metadata_json={
                    "old_rating": float(old_rating),
                    "new_rating": float(new_rating),
                    "delta": float(delta),
                },
            )
        )

    def notify_friend_request(
        self,
        *,
        recipient_user_id: UUID,
        requester_name: str,
        actor_user_id: UUID | None = None,
        action_url: str | None = None,
    ) -> Notification:
        return self.create_notification(
            NotificationCreate(
                recipient_user_id=recipient_user_id,
                notification_type="friend_request",
                category="social",
                title="New friend request",
                body=f"{requester_name} sent you a friend request.",
                action_url=action_url,
                actor_user_id=actor_user_id,
                metadata_json={"requester_name": requester_name},
            )
        )

    def notify_message_received(
        self,
        *,
        recipient_user_id: UUID,
        sender_name: str,
        preview: str,
        actor_user_id: UUID | None = None,
        action_url: str | None = None,
    ) -> Notification:
        return self.create_notification(
            NotificationCreate(
                recipient_user_id=recipient_user_id,
                notification_type="message",
                category="message",
                title=f"Message from {sender_name}",
                body=preview,
                action_url=action_url,
                actor_user_id=actor_user_id,
                metadata_json={"sender_name": sender_name, "preview": preview},
            )
        )

    def notify_match_alert(
        self,
        *,
        recipient_user_id: UUID,
        title: str,
        body: str,
        actor_user_id: UUID | None = None,
        related_entity_type: str | None = "match",
        related_entity_id: UUID | None = None,
        action_url: str | None = None,
        category: str = "match",
        metadata_json: dict | None = None,
    ) -> Notification:
        return self.create_notification(
            NotificationCreate(
                recipient_user_id=recipient_user_id,
                notification_type="match_alert",
                category=category,
                title=title,
                body=body,
                action_url=action_url,
                actor_user_id=actor_user_id,
                related_entity_type=related_entity_type,
                related_entity_id=related_entity_id,
                metadata_json=metadata_json,
            )
        )

    def notify_match_participants(
        self,
        *,
        participant_user_ids: list[UUID],
        title: str,
        body: str,
        actor_user_id: UUID | None = None,
        related_entity_id: UUID | None = None,
        action_url: str | None = None,
        category: str = "match",
        metadata_json: dict | None = None,
    ) -> list[Notification]:
        created: list[Notification] = []
        for recipient_user_id in participant_user_ids:
            created.append(
                self.notify_match_alert(
                    recipient_user_id=recipient_user_id,
                    title=title,
                    body=body,
                    actor_user_id=actor_user_id,
                    related_entity_id=related_entity_id,
                    action_url=action_url,
                    category=category,
                    metadata_json=metadata_json,
                )
            )
        return created
