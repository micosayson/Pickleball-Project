from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_principal, get_tenant_context
from app.core.security import Principal
from app.core.tenancy import TenantContext
from app.db.session import get_db
from app.modules.rankings.repository import RankingRepository
from app.modules.rankings.schemas import RankingCreate, RankingRead, RankingUpdate
from app.modules.rankings.service import RankingService

router = APIRouter()


def _service(db: Session) -> RankingService:
    return RankingService(RankingRepository(db))


@router.get("", response_model=list[RankingRead])
def list_rankings(
    event_id: UUID | None = None,
    user_id: UUID | None = None,
    limit: int = Query(default=50, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).list_rankings(
        scope,
        event_id=event_id,
        user_id=user_id,
        limit=limit,
        offset=offset,
    )


@router.post("", response_model=RankingRead, status_code=status.HTTP_201_CREATED)
def create_ranking(
    payload: RankingCreate,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).create_ranking(payload, scope)


@router.get("/{ranking_id}", response_model=RankingRead)
def read_ranking(
    ranking_id: UUID,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).get_ranking(ranking_id, scope)


@router.patch("/{ranking_id}", response_model=RankingRead)
def update_ranking(
    ranking_id: UUID,
    payload: RankingUpdate,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).update_ranking(ranking_id, payload, scope)


@router.delete("/{ranking_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_ranking(
    ranking_id: UUID,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    _service(db).delete_ranking(ranking_id, scope)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
