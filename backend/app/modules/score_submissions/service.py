from datetime import UTC, datetime
from uuid import UUID

from fastapi import HTTPException, status

from app.core.audit import add_audit_log
from app.core.tenancy import TenantContext
from app.modules.event_queue.models import EventQueueEntry
from app.modules.event_queue.repository import EventQueueRepository
from app.modules.match_participants.models import MatchParticipant
from app.modules.matches.models import Match
from app.modules.score_submissions.models import ScoreSubmission
from app.modules.score_submissions.repository import ScoreSubmissionRepository
from app.modules.score_submissions.schemas import ScoreSubmissionCreate, ScoreSubmissionReject


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

    def get_score_submission(
        self,
        score_submission_id: UUID,
        scope: TenantContext,
    ) -> ScoreSubmission:
        score_submission = self.repository.get_by_id(score_submission_id)
        if score_submission is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Score submission not found",
            )
        self._ensure_court_access(scope, score_submission.court_id)
        return score_submission

    def create_score_submission(
        self,
        payload: ScoreSubmissionCreate,
        scope: TenantContext,
    ) -> ScoreSubmission:
        user_id = self._backend_user_id(scope)
        match = self._get_match(payload.match_id, scope)
        if not self._can_submit_for_match(match.id, user_id, scope, match.court_id):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only match participants or court operators can submit this score",
            )
        existing = (
            self.repository.db.query(ScoreSubmission)
            .filter(
                ScoreSubmission.match_id == match.id,
                ScoreSubmission.status.in_(["pending", "verified"]),
            )
            .first()
        )
        if existing is not None:
            return existing

        now = datetime.now(UTC)
        score_submission = ScoreSubmission(
            court_id=match.court_id,
            event_id=match.event_id,
            match_id=match.id,
            submitted_by_user_id=user_id,
            status="pending",
            source="player",
            team_one_score=payload.team_one_score,
            team_two_score=payload.team_two_score,
            submitted_at=now,
            notes=payload.notes,
            created_by_user_id=user_id,
        )
        match.status = "pending_verification"
        match.ended_at = now
        self.repository.db.add(score_submission)
        self.repository.db.flush()
        add_audit_log(
            self.repository.db,
            action="score.submit",
            entity_type="score_submission",
            actor_user_id=user_id,
            entity_id=score_submission.id,
            court_id=match.court_id,
            event_id=match.event_id,
            match_id=match.id,
            details={
                "team_one_score": payload.team_one_score,
                "team_two_score": payload.team_two_score,
            },
        )
        self.repository.db.commit()
        self.repository.db.refresh(score_submission)
        return score_submission

    def verify_score_submission(
        self,
        score_submission_id: UUID,
        scope: TenantContext,
    ) -> ScoreSubmission:
        verifier_id = self._backend_user_id(scope)
        score_submission = self.get_score_submission(score_submission_id, scope)
        if not scope.can_operate_court(str(score_submission.court_id)):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only court operators can verify scores",
            )
        if score_submission.status != "pending":
            return score_submission

        now = datetime.now(UTC)
        match = self._get_match(score_submission.match_id, scope)
        winner_team_number = 1 if score_submission.team_one_score > score_submission.team_two_score else 2
        score_submission.status = "verified"
        score_submission.verified_by_user_id = verifier_id
        score_submission.verified_at = now
        match.status = "verified"
        match.winner_team_number = winner_team_number
        self._return_players_to_queue(match, verifier_id=verifier_id, returned_at=now)
        add_audit_log(
            self.repository.db,
            action="score.verify",
            entity_type="score_submission",
            actor_user_id=verifier_id,
            entity_id=score_submission.id,
            court_id=match.court_id,
            event_id=match.event_id,
            match_id=match.id,
            details={"winner_team_number": winner_team_number},
        )
        self.repository.db.commit()
        self.repository.db.refresh(score_submission)
        return score_submission

    def reject_score_submission(
        self,
        score_submission_id: UUID,
        payload: ScoreSubmissionReject,
        scope: TenantContext,
    ) -> ScoreSubmission:
        verifier_id = self._backend_user_id(scope)
        score_submission = self.get_score_submission(score_submission_id, scope)
        if not scope.can_operate_court(str(score_submission.court_id)):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only court operators can reject scores",
            )
        if score_submission.status != "pending":
            return score_submission
        now = datetime.now(UTC)
        match = self._get_match(score_submission.match_id, scope)
        score_submission.status = "rejected"
        score_submission.rejected_at = now
        score_submission.dispute_reason = payload.dispute_reason
        match.status = "active"
        match.ended_at = None
        add_audit_log(
            self.repository.db,
            action="score.reject",
            entity_type="score_submission",
            actor_user_id=verifier_id,
            entity_id=score_submission.id,
            court_id=match.court_id,
            event_id=match.event_id,
            match_id=match.id,
            details={"dispute_reason": payload.dispute_reason},
        )
        self.repository.db.commit()
        self.repository.db.refresh(score_submission)
        return score_submission

    def _get_match(self, match_id: UUID, scope: TenantContext) -> Match:
        query = self.repository.db.query(Match).filter(Match.id == match_id, Match.deleted_at.is_(None))
        if scope.court_id:
            query = query.filter(Match.court_id == UUID(scope.court_id))
        match = query.one_or_none()
        if match is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Match not found")
        return match

    def _return_players_to_queue(
        self,
        match: Match,
        *,
        verifier_id: UUID,
        returned_at: datetime,
    ) -> None:
        queue_repo = EventQueueRepository(self.repository.db)
        entries = (
            self.repository.db.query(EventQueueEntry)
            .filter(
                EventQueueEntry.assigned_match_id == match.id,
                EventQueueEntry.deleted_at.is_(None),
            )
            .order_by(EventQueueEntry.assigned_at.asc())
            .all()
        )
        for entry in entries:
            entry.status = "queued"
            entry.assigned_match_id = None
            entry.queue_position = queue_repo.next_queue_position(match.event_id)
            entry.returned_at = returned_at
            entry.updated_by_user_id = verifier_id

    def _can_submit_for_match(
        self,
        match_id: UUID,
        user_id: UUID,
        scope: TenantContext,
        court_id: UUID,
    ) -> bool:
        if scope.can_operate_court(str(court_id)):
            return True
        participant = (
            self.repository.db.query(MatchParticipant)
            .filter(
                MatchParticipant.match_id == match_id,
                MatchParticipant.user_id == user_id,
                MatchParticipant.status == "active",
            )
            .one_or_none()
        )
        return participant is not None

    def _ensure_court_access(self, scope: TenantContext, court_id: UUID) -> None:
        if scope.court_id and str(court_id) != scope.court_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Court scope mismatch")
        if not scope.can_access_court(str(court_id)) and not scope.is_platform_admin:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Court access denied")

    def _backend_user_id(self, scope: TenantContext) -> UUID:
        if scope.backend_user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Authenticated user profile is required",
            )
        return UUID(scope.backend_user_id)
