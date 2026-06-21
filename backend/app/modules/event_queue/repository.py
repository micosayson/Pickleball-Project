from uuid import UUID

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.modules.event_queue.models import EventQueueEntry


class EventQueueRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_for_event_user(self, event_id: UUID, user_id: UUID) -> EventQueueEntry | None:
        return (
            self.db.query(EventQueueEntry)
            .filter(
                EventQueueEntry.event_id == event_id,
                EventQueueEntry.user_id == user_id,
                EventQueueEntry.deleted_at.is_(None),
            )
            .one_or_none()
        )

    def next_queue_position(self, event_id: UUID) -> int:
        current = (
            self.db.query(func.max(EventQueueEntry.queue_position))
            .filter(
                EventQueueEntry.event_id == event_id,
                EventQueueEntry.status == "queued",
                EventQueueEntry.deleted_at.is_(None),
            )
            .scalar()
        )
        return int(current or 0) + 1

    def list_matchable(self, event_id: UUID, *, limit: int = 4) -> list[EventQueueEntry]:
        return (
            self.db.query(EventQueueEntry)
            .filter(
                EventQueueEntry.event_id == event_id,
                EventQueueEntry.status == "queued",
                EventQueueEntry.assigned_match_id.is_(None),
                EventQueueEntry.deleted_at.is_(None),
            )
            .order_by(EventQueueEntry.queue_position.asc(), EventQueueEntry.checked_in_at.asc())
            .limit(limit)
            .all()
        )

    def create(self, entry: EventQueueEntry) -> EventQueueEntry:
        self.db.add(entry)
        return entry
