from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_principal, get_tenant_context
from app.core.security import Principal
from app.core.tenancy import TenantContext
from app.db.session import get_db
from app.modules.court_memberships.repository import CourtMembershipRepository
from app.modules.court_memberships.schemas import CourtMembershipRead
from app.modules.court_memberships.service import CourtMembershipService

router = APIRouter()


def _service(db: Session) -> CourtMembershipService:
    return CourtMembershipService(CourtMembershipRepository(db))


@router.get("/me", response_model=list[CourtMembershipRead])
def list_my_court_memberships(
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).list_my_memberships(scope, limit=limit, offset=offset)


@router.post("/{court_id}", response_model=CourtMembershipRead)
def join_court(
    court_id: UUID,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).join_court(court_id, scope)


@router.delete("/{court_id}", response_model=CourtMembershipRead)
def leave_court(
    court_id: UUID,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).leave_court(court_id, scope)
