from datetime import UTC, datetime
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.core.audit import add_audit_log
from app.core.tenancy import TenantContext
from app.modules.event_queue.models import EventQueueEntry
from app.modules.event_queue.repository import EventQueueRepository
from app.modules.event_queue.schemas import (
    EventQueueEntryRead,
    PlayerEventStatusRead,
    PlayerMatchParticipantRead,
    PlayerMatchRead,
)
from app.modules.event_registrations.models import EventRegistration
from app.modules.event_registrations.schemas import EventRegistrationRead
from app.modules.events.models import Event
from app.modules.match_participants.models import MatchParticipant
from app.modules.matches.models import Match
from app.modules.score_submissions.models import ScoreSubmission
from app.modules.score_submissions.schemas import ScoreSubmissionRead
from app.modules.users.models import User


class EventQueueService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.queue = EventQueueRepository(db)

    def check_in_event(self, event_id: UUID, scope: TenantContext) -> PlayerEventStatusRead:
        user_id = self._backend_user_id(scope)
        event = self._get_event(event_id, scope)
        if event.status not in {"published", "open", "scheduled", "in_progress"}:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Event lobby is not open",
            )

        now = datetime.now(UTC)
        registration = self._get_registration(event_id, user_id)
        if registration is None:
            registration = EventRegistration(
                court_id=event.court_id,
                event_id=event.id,
                user_id=user_id,
                status="checked_in",
                checked_in_at=now,
            )
            self.db.add(registration)
            self.db.flush()
        else:
            registration.status = "checked_in"
            registration.cancelled_at = None
            registration.checked_in_at = registration.checked_in_at or now
            registration.checked_out_at = None

        entry = self.queue.get_for_event_user(event.id, user_id)
        if entry is None:
            entry = self.queue.create(
                EventQueueEntry(
                    court_id=event.court_id,
                    event_id=event.id,
                    registration_id=registration.id,
                    user_id=user_id,
                    status="queued",
                    queue_position=self.queue.next_queue_position(event.id),
                    checked_in_at=now,
                    created_by_user_id=user_id,
                )
            )
        elif entry.status in {"left", "cancelled", "verified"}:
            entry.status = "queued"
            entry.queue_position = self.queue.next_queue_position(event.id)
            entry.assigned_match_id = None
            entry.left_at = None
            entry.returned_at = now
            entry.updated_by_user_id = user_id

        self.db.flush()
        add_audit_log(
            self.db,
            action="event.check_in",
            entity_type="event_registration",
            actor_user_id=user_id,
            entity_id=registration.id,
            court_id=event.court_id,
            event_id=event.id,
            details={"queue_entry_id": str(entry.id)},
        )
        self._try_create_match(event, actor_user_id=user_id)
        self.db.commit()
        return self.get_player_status(event_id, scope)

    def get_player_status(self, event_id: UUID, scope: TenantContext) -> PlayerEventStatusRead:
        user_id = self._backend_user_id(scope)
        event = self._get_event(event_id, scope)
        registration = self._get_registration(event.id, user_id)
        queue_entry = self.queue.get_for_event_user(event.id, user_id)
        match = self._current_match(queue_entry)
        score_submission = self._latest_score_submission(match.id) if match is not None else None

        phase = "no_registration"
        if registration is not None:
            phase = registration.status
        if queue_entry is not None:
            phase = queue_entry.status
        if match is not None:
            if score_submission is not None and score_submission.status == "pending":
                phase = "score_pending"
            elif match.status in {"pending_verification", "verified"}:
                phase = match.status
            else:
                phase = match.status

        return PlayerEventStatusRead(
            event_id=event.id,
            court_id=event.court_id,
            phase=phase,
            registration=EventRegistrationRead.model_validate(registration)
            if registration is not None
            else None,
            queue_entry=EventQueueEntryRead.model_validate(queue_entry)
            if queue_entry is not None
            else None,
            match=self._read_match(match) if match is not None else None,
            score_submission=ScoreSubmissionRead.model_validate(score_submission)
            if score_submission is not None
            else None,
        )

    def leave_event(self, event_id: UUID, scope: TenantContext) -> PlayerEventStatusRead:
        user_id = self._backend_user_id(scope)
        event = self._get_event(event_id, scope)
        registration = self._get_registration(event.id, user_id)
        queue_entry = self.queue.get_for_event_user(event.id, user_id)
        now = datetime.now(UTC)
        if registration is not None:
            registration.status = "cancelled"
            registration.cancelled_at = now
            registration.checked_out_at = now
        if queue_entry is not None:
            queue_entry.status = "left"
            queue_entry.queue_position = None
            queue_entry.left_at = now
            queue_entry.updated_by_user_id = user_id
            add_audit_log(
                self.db,
                action="event.leave_queue",
                entity_type="event_queue_entry",
                actor_user_id=user_id,
                entity_id=queue_entry.id,
                court_id=event.court_id,
                event_id=event.id,
            )
        self.db.commit()
        return self.get_player_status(event_id, scope)

    def _try_create_match(self, event: Event, *, actor_user_id: UUID) -> Match | None:
        queued = self.queue.list_matchable(event.id, limit=4)
        if len(queued) < 4:
            return None

        now = datetime.now(UTC)
        next_match_number = (
            self.db.query(func.max(Match.match_number))
            .filter(Match.event_id == event.id, Match.deleted_at.is_(None))
            .scalar()
        )
        match = Match(
            court_id=event.court_id,
            event_id=event.id,
            match_number=int(next_match_number or 0) + 1,
            match_type="doubles",
            status="assigned",
            scheduled_at=now,
            created_by_user_id=actor_user_id,
        )
        self.db.add(match)
        self.db.flush()

        team_numbers = [1, 2, 1, 2]
        for index, entry in enumerate(queued):
            self.db.add(
                MatchParticipant(
                    match_id=match.id,
                    user_id=entry.user_id,
                    team_number=team_numbers[index],
                    slot_number=index + 1,
                    role="player",
                    status="active",
                    created_by_user_id=actor_user_id,
                )
            )
            entry.status = "assigned"
            entry.assigned_match_id = match.id
            entry.assigned_at = now
            entry.queue_position = None
            entry.updated_by_user_id = actor_user_id

        add_audit_log(
            self.db,
            action="match.auto_assign",
            entity_type="match",
            actor_user_id=actor_user_id,
            entity_id=match.id,
            court_id=event.court_id,
            event_id=event.id,
            match_id=match.id,
            details={"queued_user_ids": [str(entry.user_id) for entry in queued]},
        )
        return match

    def _get_event(self, event_id: UUID, scope: TenantContext) -> Event:
        query = self.db.query(Event).filter(Event.id == event_id, Event.deleted_at.is_(None))
        if scope.court_id:
            query = query.filter(Event.court_id == UUID(scope.court_id))
        event = query.one_or_none()
        if event is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")
        return event

    def _get_registration(self, event_id: UUID, user_id: UUID) -> EventRegistration | None:
        return (
            self.db.query(EventRegistration)
            .filter(
                EventRegistration.event_id == event_id,
                EventRegistration.user_id == user_id,
                EventRegistration.deleted_at.is_(None),
            )
            .one_or_none()
        )

    def _current_match(self, queue_entry: EventQueueEntry | None) -> Match | None:
        if queue_entry is None or queue_entry.assigned_match_id is None:
            return None
        return (
            self.db.query(Match)
            .filter(Match.id == queue_entry.assigned_match_id, Match.deleted_at.is_(None))
            .one_or_none()
        )

    def _latest_score_submission(self, match_id: UUID) -> ScoreSubmission | None:
        return (
            self.db.query(ScoreSubmission)
            .filter(ScoreSubmission.match_id == match_id)
            .order_by(ScoreSubmission.submitted_at.desc())
            .first()
        )

    def _read_match(self, match: Match) -> PlayerMatchRead:
        participants = (
            self.db.query(MatchParticipant, User.full_name, User.email)
            .join(User, User.id == MatchParticipant.user_id)
            .filter(MatchParticipant.match_id == match.id)
            .order_by(MatchParticipant.team_number.asc(), MatchParticipant.slot_number.asc())
            .all()
        )
        return PlayerMatchRead(
            id=match.id,
            court_id=match.court_id,
            event_id=match.event_id,
            match_number=match.match_number,
            round_number=match.round_number,
            match_type=match.match_type,
            status=match.status,
            scheduled_at=match.scheduled_at,
            started_at=match.started_at,
            ended_at=match.ended_at,
            winner_team_number=match.winner_team_number,
            participants=[
                PlayerMatchParticipantRead(
                    id=participant.id,
                    match_id=participant.match_id,
                    user_id=participant.user_id,
                    team_number=participant.team_number,
                    slot_number=participant.slot_number,
                    role=participant.role,
                    status=participant.status,
                    display_name=full_name or email,
                )
                for participant, full_name, email in participants
            ],
        )

    def _backend_user_id(self, scope: TenantContext) -> UUID:
        if scope.backend_user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Authenticated user profile is required",
            )
        return UUID(scope.backend_user_id)
