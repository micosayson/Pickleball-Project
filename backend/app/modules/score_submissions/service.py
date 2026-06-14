from uuid import UUID

from app.core.tenancy import TenantContext
from app.modules.score_submissions.models import ScoreSubmission
from app.modules.score_submissions.repository import ScoreSubmissionRepository


class ScoreSubmissionService:
    def __init__(self, repository: ScoreSubmissionRepository) -> None:
        self.repository = repository

    def list_score_submissions(
        self,
        *,
        scope: TenantContext | None = None,
        court_id: UUID | None,
        event_id: UUID | None,
        match_id: UUID | None,
        status: str | None,
        limit: int,
        offset: int,
    ) -> list[ScoreSubmission]:
        return self.repository.list(
            scope=scope,
            court_id=court_id,
            event_id=event_id,
            match_id=match_id,
            status=status,
            limit=limit,
            offset=offset,
        )
