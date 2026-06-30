from datetime import UTC, datetime
from uuid import UUID

from fastapi import HTTPException, status

from app.core.audit import add_audit_log
from app.core.tenancy import TenantContext
from app.modules.match_participants.models import MatchParticipant
from app.modules.matches.models import Match
from app.modules.matches.repository import MatchRepository
from app.modules.matches.schemas import MatchCreate, MatchUpdate
from app.modules.notifications.repository import NotificationRepository
from app.modules.notifications.service import NotificationService


class MatchService:
    def __init__(self, repository: MatchRepository) -> None:
        self.repository = repository

    def list_matches(
        self,
        scope: TenantContext,
        *,
        event_id: UUID | None,
        limit: int,
        offset: int,
    ) -> list[Match]:
        return self.repository.list(scope, event_id=event_id, limit=limit, offset=offset)

    def get_match(self, match_id: UUID, scope: TenantContext) -> Match:
        match = self.repository.get_by_id(match_id, scope)
        if match is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Match not found")
        return match

    def create_match(self, payload: MatchCreate, scope: TenantContext) -> Match:
        if scope.court_id and str(payload.court_id) != scope.court_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Match court does not match request court scope",
            )
        return self.repository.create(Match(**payload.model_dump()))

    def update_match(self, match_id: UUID, payload: MatchUpdate, scope: TenantContext) -> Match:
        match = self.get_match(match_id, scope)
        values = payload.model_dump(exclude_unset=True)
        if scope.court_id and "court_id" in values and str(values["court_id"]) != scope.court_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Match court does not match request court scope",
            )
        return self.repository.update(match, values)

    def delete_match(self, match_id: UUID, scope: TenantContext) -> None:
        match = self.get_match(match_id, scope)
        self.repository.delete(match)

    def start_match(self, match_id: UUID, scope: TenantContext) -> Match:
        user_id = self._backend_user_id(scope)
        match = self.get_match(match_id, scope)
        if not scope.can_operate_court(str(match.court_id)):
            participant = (
                self.repository.db.query(MatchParticipant)
                .filter(
                    MatchParticipant.match_id == match.id,
                    MatchParticipant.user_id == user_id,
                    MatchParticipant.status == "active",
                )
                .one_or_none()
            )
            if participant is None:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Only match participants or court operators can start this match",
                )
        if match.status == "assigned":
            match.status = "active"
            match.started_at = datetime.now(UTC)
            match.updated_by_user_id = user_id
            add_audit_log(
                self.repository.db,
                action="match.start",
                entity_type="match",
                actor_user_id=user_id,
                entity_id=match.id,
                court_id=match.court_id,
                event_id=match.event_id,
                match_id=match.id,
            )
            self.repository.db.add(match)
            self.repository.db.commit()
            self.repository.db.refresh(match)
            self._notify_participants(
                match,
                title=f"Match #{match.match_number} is live",
                body="Your match has started. Head to the court and get ready to play.",
                actor_user_id=user_id,
                category="match",
            )
        return match

    def _backend_user_id(self, scope: TenantContext) -> UUID:
        if scope.backend_user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Authenticated user profile is required",
            )
        return UUID(scope.backend_user_id)

    def _notify_participants(
        self,
        match: Match,
        *,
        title: str,
        body: str,
        actor_user_id: UUID | None,
        category: str,
    ) -> None:
        participant_ids = [
            participant.user_id
            for participant in self.repository.db.query(MatchParticipant)
            .filter(MatchParticipant.match_id == match.id, MatchParticipant.status == "active")
            .all()
        ]
        if not participant_ids:
            return
        NotificationService(NotificationRepository(self.repository.db)).notify_match_participants(
            participant_user_ids=participant_ids,
            title=title,
            body=body,
            actor_user_id=actor_user_id,
            related_entity_id=match.id,
            action_url=f"/player/matches/{match.id}",
            category=category,
            metadata_json={
                "match_number": match.match_number,
                "court_id": str(match.court_id),
                "event_id": str(match.event_id),
            },
        )
