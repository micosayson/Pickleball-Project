from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_principal, get_tenant_context
from app.core.security import Principal
from app.core.tenancy import TenantContext
from app.db.session import get_db
from app.modules.ratings.repository import RatingRepository
from app.modules.ratings.schemas import RatingCreate, RatingRead, RatingUpdate
from app.modules.ratings.service import RatingService

router = APIRouter()


def _service(db: Session) -> RatingService:
    return RatingService(RatingRepository(db))


@router.get("", response_model=list[RatingRead])
def list_ratings(
    user_id: UUID | None = None,
    limit: int = Query(default=50, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).list_ratings(scope, user_id=user_id, limit=limit, offset=offset)


@router.post("", response_model=RatingRead, status_code=status.HTTP_201_CREATED)
def create_rating(
    payload: RatingCreate,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).create_rating(payload, scope)


@router.get("/{rating_id}", response_model=RatingRead)
def read_rating(
    rating_id: UUID,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).get_rating(rating_id, scope)


@router.patch("/{rating_id}", response_model=RatingRead)
def update_rating(
    rating_id: UUID,
    payload: RatingUpdate,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).update_rating(rating_id, payload, scope)


@router.delete("/{rating_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_rating(
    rating_id: UUID,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    _service(db).delete_rating(rating_id, scope)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
