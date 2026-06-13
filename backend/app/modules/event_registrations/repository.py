from uuid import UUID

from sqlalchemy.orm import Session

from app.core.tenancy import TenantContext
from app.modules.event_registrations.models import EventRegistration
from app.modules.events.models import Event


class EventRegistrationRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def _registration_query(self, scope: TenantContext):
        query = self.db.query(EventRegistration).filter(EventRegistration.deleted_at.is_(None))
        if scope.court_id:
            query = query.filter(EventRegistration.court_id == UUID(scope.court_id))
        return query

    def _event_query(self, scope: TenantContext):
        query = self.db.query(Event).filter(Event.deleted_at.is_(None))
        if scope.court_id:
            query = query.filter(Event.court_id == UUID(scope.court_id))
        return query

    def list_for_user(
        self,
        scope: TenantContext,
        *,
        user_id: UUID,
        limit: int = 50,
        offset: int = 0,
    ) -> list[EventRegistration]:
        return (
            self._registration_query(scope)
            .filter(EventRegistration.user_id == user_id)
            .order_by(EventRegistration.registered_at.desc())
            .offset(offset)
            .limit(limit)
            .all()
        )

    def get_event(self, event_id: UUID, scope: TenantContext) -> Event | None:
        return self._event_query(scope).filter(Event.id == event_id).one_or_none()

    def get_for_event_user(self, event_id: UUID, user_id: UUID) -> EventRegistration | None:
        return (
            self.db.query(EventRegistration)
            .filter(
                EventRegistration.event_id == event_id,
                EventRegistration.user_id == user_id,
                EventRegistration.deleted_at.is_(None),
            )
            .one_or_none()
        )

    def create(self, registration: EventRegistration) -> EventRegistration:
        self.db.add(registration)
        self.db.commit()
        self.db.refresh(registration)
        return registration

    def update(self, registration: EventRegistration, values: dict) -> EventRegistration:
        for key, value in values.items():
            setattr(registration, key, value)
        self.db.add(registration)
        self.db.commit()
        self.db.refresh(registration)
        return registration
