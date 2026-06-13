from uuid import UUID

from fastapi import HTTPException, status

from app.core.tenancy import TenantContext
from app.modules.events.models import Event
from app.modules.events.repository import EventRepository
from app.modules.events.schemas import EventCreate, EventUpdate


class EventService:
    def __init__(self, repository: EventRepository) -> None:
        self.repository = repository

    def list_events(self, scope: TenantContext, *, limit: int, offset: int) -> list[Event]:
        return self.repository.list(scope, limit=limit, offset=offset)

    def get_event(self, event_id: UUID, scope: TenantContext) -> Event:
        event = self.repository.get_by_id(event_id, scope)
        if event is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")
        return event

    def create_event(self, payload: EventCreate, scope: TenantContext) -> Event:
        tenant_id = payload.tenant_id or scope.tenant_id
        if tenant_id is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="tenant_id is required in the payload or X-Tenant-ID header",
            )
        if scope.court_id and str(payload.court_id) != scope.court_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Event court does not match request court scope",
            )

        return self.repository.create(
            Event(
                tenant_id=UUID(str(tenant_id)),
                **payload.model_dump(exclude={"tenant_id"}),
            )
        )

    def update_event(self, event_id: UUID, payload: EventUpdate, scope: TenantContext) -> Event:
        event = self.get_event(event_id, scope)
        values = payload.model_dump(exclude_unset=True)
        if scope.court_id and "court_id" in values and str(values["court_id"]) != scope.court_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Event court does not match request court scope",
            )
        return self.repository.update(event, values)

    def delete_event(self, event_id: UUID, scope: TenantContext) -> None:
        event = self.get_event(event_id, scope)
        self.repository.delete(event)
