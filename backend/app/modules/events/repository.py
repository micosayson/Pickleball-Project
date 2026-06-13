from uuid import UUID

from sqlalchemy.orm import Session

from app.core.tenancy import TenantContext
from app.modules.events.models import Event


class EventRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def _scoped_query(self, scope: TenantContext):
        query = self.db.query(Event).filter(Event.deleted_at.is_(None))
        if scope.court_id:
            query = query.filter(Event.court_id == UUID(scope.court_id))
        return query

    def list(self, scope: TenantContext, *, limit: int = 50, offset: int = 0) -> list[Event]:
        return (
            self._scoped_query(scope)
            .order_by(Event.start_at.asc())
            .offset(offset)
            .limit(limit)
            .all()
        )

    def get_by_id(self, event_id: UUID, scope: TenantContext) -> Event | None:
        return self._scoped_query(scope).filter(Event.id == event_id).one_or_none()

    def create(self, event: Event) -> Event:
        self.db.add(event)
        self.db.commit()
        self.db.refresh(event)
        return event

    def update(self, event: Event, values: dict) -> Event:
        for key, value in values.items():
            setattr(event, key, value)
        self.db.add(event)
        self.db.commit()
        self.db.refresh(event)
        return event

    def delete(self, event: Event) -> None:
        self.db.delete(event)
        self.db.commit()
