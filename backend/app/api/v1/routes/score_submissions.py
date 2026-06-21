from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_principal, get_tenant_context
from app.core.security import Principal
from app.core.tenancy import TenantContext
from app.db.session import get_db
from app.modules.score_submissions.repository import ScoreSubmissionRepository
from app.modules.score_submissions.schemas import (
    ScoreSubmissionCreate,
    ScoreSubmissionRead,
    ScoreSubmissionReject,
)
from app.modules.score_submissions.service import ScoreSubmissionService

router = APIRouter()


def _service(db: Session) -> ScoreSubmissionService:
    return ScoreSubmissionService(ScoreSubmissionRepository(db))


@router.get("", response_model=list[ScoreSubmissionRead])
def list_score_submissions(
    court_id: UUID | None = None,
    event_id: UUID | None = None,
    match_id: UUID | None = None,
    status: str | None = Query(default=None),
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).list_score_submissions(
        scope=scope,
        court_id=court_id,
        event_id=event_id,
        match_id=match_id,
        status=status,
        limit=limit,
        offset=offset,
    )


@router.post("", response_model=ScoreSubmissionRead, status_code=status.HTTP_201_CREATED)
def create_score_submission(
    payload: ScoreSubmissionCreate,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).create_score_submission(payload, scope)


@router.get("/{score_submission_id}", response_model=ScoreSubmissionRead)
def read_score_submission(
    score_submission_id: UUID,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).get_score_submission(score_submission_id, scope)


@router.post("/{score_submission_id}/verify", response_model=ScoreSubmissionRead)
def verify_score_submission(
    score_submission_id: UUID,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).verify_score_submission(score_submission_id, scope)


@router.post("/{score_submission_id}/reject", response_model=ScoreSubmissionRead)
def reject_score_submission(
    score_submission_id: UUID,
    payload: ScoreSubmissionReject,
    _: Principal = Depends(get_current_principal),
    scope: TenantContext = Depends(get_tenant_context),
    db: Session = Depends(get_db),
):
    return _service(db).reject_score_submission(score_submission_id, payload, scope)
