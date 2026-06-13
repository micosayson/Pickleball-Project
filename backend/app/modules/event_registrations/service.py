from datetime import UTC, datetime
from uuid import UUID

from fastapi import HTTPException, status

from app.core.tenancy import TenantContext
from app.modules.event_registrations.models import EventRegistration
from app.modules.event_registrations.repository import EventRegistrationRepository


class EventRegistrationService:
    def __init__(self, repository: EventRegistrationRepository) -> None:
        self.repository = repository

    def list_my_registrations(
        self,
        scope: TenantContext,
        *,
        limit: int,
        offset: int,
    ) -> list[EventRegistration]:
        user_id = self._backend_user_id(scope)
        return self.repository.list_for_user(scope, user_id=user_id, limit=limit, offset=offset)

    def join_event(self, event_id: UUID, scope: TenantContext) -> EventRegistration:
        user_id = self._backend_user_id(scope)
        event = self.repository.get_event(event_id, scope)
        if event is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")
        if event.status not in {"published", "open", "scheduled", "in_progress"}:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Event is not open for registration",
            )

        existing = self.repository.get_for_event_user(event_id, user_id)
        if existing is not None:
            if existing.status == "cancelled":
                return self.repository.update(
                    existing,
                    {
                        "status": "registered",
                        "cancelled_at": None,
                        "registered_at": datetime.now(UTC),
                    },
                )
            return existing

        return self.repository.create(
            EventRegistration(
                court_id=event.court_id,
                event_id=event.id,
                user_id=user_id,
                status="registered",
            )
        )

    def cancel_event_registration(self, event_id: UUID, scope: TenantContext) -> EventRegistration:
        user_id = self._backend_user_id(scope)
        event = self.repository.get_event(event_id, scope)
        if event is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")

        registration = self.repository.get_for_event_user(event_id, user_id)
        if registration is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Registration not found")

        return self.repository.update(
            registration,
            {
                "status": "cancelled",
                "cancelled_at": datetime.now(UTC),
            },
        )

    def _backend_user_id(self, scope: TenantContext) -> UUID:
        if scope.backend_user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Authenticated user profile is required",
            )
        return UUID(scope.backend_user_id)
