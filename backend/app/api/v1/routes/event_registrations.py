from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_principal, get_tenant_context
from app.core.security import Principal
from app.core.tenancy import TenantContext
from app.db.session import get_db
from app.modules.event_registrations.repository import EventRegistrationRepository
from app.modules.event_registrations.schemas import EventRegistrationRead
from app.modules.event_registrations.service import EventRegistrationService

router = APIRouter()


def _service(db: Session) -> EventRegistrationService:
    return EventRegistrationService(EventRegistrationRepository(db))


@router.get("/me", response_model=list[EventRegistrationRead])
def list_my_event_registrations(
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).list_my_registrations(scope, limit=limit, offset=offset)


@router.post("/{event_id}", response_model=EventRegistrationRead)
def join_event(
    event_id: UUID,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).join_event(event_id, scope)


@router.post("/{event_id}/check-in", response_model=EventRegistrationRead)
def check_in_event(
    event_id: UUID,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).check_in_event(event_id, scope)


@router.delete("/{event_id}", response_model=EventRegistrationRead)
def cancel_event_registration(
    event_id: UUID,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).cancel_event_registration(event_id, scope)
