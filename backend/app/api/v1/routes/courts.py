from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_principal, get_tenant_context
from app.core.security import Principal
from app.core.tenancy import TenantContext
from app.db.session import get_db
from app.modules.courts.repository import CourtRepository
from app.modules.courts.schemas import CourtCreate, CourtRead, CourtUpdate
from app.modules.courts.service import CourtService

router = APIRouter()


def _service(db: Session) -> CourtService:
    return CourtService(CourtRepository(db))


@router.get("", response_model=list[CourtRead])
def list_courts(
    status: str | None = Query(default="active"),
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).list_courts(scope=scope, status=status, limit=limit, offset=offset)


@router.post("", response_model=CourtRead, status_code=status.HTTP_201_CREATED)
def create_court(
    payload: CourtCreate,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).create_court(payload, scope)


@router.get("/{court_id}", response_model=CourtRead)
def read_court(
    court_id: UUID,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).get_court(court_id, scope)


@router.patch("/{court_id}", response_model=CourtRead)
def update_court(
    court_id: UUID,
    payload: CourtUpdate,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).update_court(court_id, payload, scope)


@router.delete("/{court_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_court(
    court_id: UUID,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    _service(db).delete_court(court_id, scope)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
