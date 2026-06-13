from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_principal, get_tenant_context
from app.core.security import Principal
from app.core.tenancy import TenantContext
from app.db.session import get_db
from app.modules.matches.repository import MatchRepository
from app.modules.matches.schemas import MatchCreate, MatchRead, MatchUpdate
from app.modules.matches.service import MatchService

router = APIRouter()


def _service(db: Session) -> MatchService:
    return MatchService(MatchRepository(db))


@router.get("", response_model=list[MatchRead])
def list_matches(
    event_id: UUID | None = None,
    limit: int = Query(default=50, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).list_matches(scope, event_id=event_id, limit=limit, offset=offset)


@router.post("", response_model=MatchRead, status_code=status.HTTP_201_CREATED)
def create_match(
    payload: MatchCreate,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).create_match(payload, scope)


@router.get("/{match_id}", response_model=MatchRead)
def read_match(
    match_id: UUID,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).get_match(match_id, scope)


@router.patch("/{match_id}", response_model=MatchRead)
def update_match(
    match_id: UUID,
    payload: MatchUpdate,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).update_match(match_id, payload, scope)


@router.delete("/{match_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_match(
    match_id: UUID,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    _service(db).delete_match(match_id, scope)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
