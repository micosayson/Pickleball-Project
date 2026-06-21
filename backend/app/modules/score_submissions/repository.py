from sqlalchemy.orm import Session
from uuid import UUID

from app.core.tenancy import TenantContext
from app.modules.score_submissions.models import ScoreSubmission


class ScoreSubmissionRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def list(
        self,
        *,
        scope: TenantContext | None = None,
        court_id: UUID | None = None,
        event_id: UUID | None = None,
        match_id: UUID | None = None,
        status: str | None = None,
        limit: int = 50,
        offset: int = 0,
    ) -> list[ScoreSubmission]:
        query = self.db.query(ScoreSubmission)
        if scope is not None:
            if scope.court_id:
                query = query.filter(ScoreSubmission.court_id == UUID(scope.court_id))
        if court_id is not None:
            query = query.filter(ScoreSubmission.court_id == court_id)
        if event_id is not None:
            query = query.filter(ScoreSubmission.event_id == event_id)
        if match_id is not None:
            query = query.filter(ScoreSubmission.match_id == match_id)
        if status is not None:
            query = query.filter(ScoreSubmission.status == status)
        return (
            query.order_by(ScoreSubmission.submitted_at.desc())
            .offset(offset)
            .limit(limit)
            .all()
        )

    def get_by_id(self, score_submission_id):
        return self.db.get(ScoreSubmission, score_submission_id)

    def create(self, score_submission: ScoreSubmission) -> ScoreSubmission:
        self.db.add(score_submission)
        self.db.commit()
        self.db.refresh(score_submission)
        return score_submission

    def update(self, score_submission: ScoreSubmission, values: dict) -> ScoreSubmission:
        for key, value in values.items():
            setattr(score_submission, key, value)
        self.db.add(score_submission)
        self.db.commit()
        self.db.refresh(score_submission)
        return score_submission
