from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_principal, get_tenant_context
from app.core.security import Principal
from app.core.tenancy import TenantContext
from app.db.session import get_db
from app.modules.events.repository import EventRepository
from app.modules.events.schemas import EventCreate, EventRead, EventUpdate
from app.modules.events.service import EventService

router = APIRouter()


def _service(db: Session) -> EventService:
    return EventService(EventRepository(db))


@router.get("", response_model=list[EventRead])
def list_events(
    limit: int = Query(default=50, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).list_events(scope, limit=limit, offset=offset)


@router.post("", response_model=EventRead, status_code=status.HTTP_201_CREATED)
def create_event(
    payload: EventCreate,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).create_event(payload, scope)


@router.get("/{event_id}", response_model=EventRead)
def read_event(
    event_id: UUID,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).get_event(event_id, scope)


@router.patch("/{event_id}", response_model=EventRead)
def update_event(
    event_id: UUID,
    payload: EventUpdate,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).update_event(event_id, payload, scope)


@router.delete("/{event_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_event(
    event_id: UUID,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    _service(db).delete_event(event_id, scope)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
