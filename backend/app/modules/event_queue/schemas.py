from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict

from app.modules.event_registrations.schemas import EventRegistrationRead
from app.modules.score_submissions.schemas import ScoreSubmissionRead


class EventQueueEntryRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    court_id: UUID
    event_id: UUID
    registration_id: UUID
    user_id: UUID
    assigned_match_id: UUID | None = None
    status: str
    queue_position: int | None = None
    checked_in_at: datetime
    assigned_at: datetime | None = None
    left_at: datetime | None = None
    returned_at: datetime | None = None


class PlayerMatchParticipantRead(BaseModel):
    id: UUID
    match_id: UUID
    user_id: UUID
    team_number: int
    slot_number: int | None = None
    role: str | None = None
    status: str
    display_name: str | None = None


class PlayerMatchRead(BaseModel):
    id: UUID
    court_id: UUID
    event_id: UUID
    match_number: int
    round_number: int | None = None
    match_type: str
    status: str
    scheduled_at: datetime | None = None
    started_at: datetime | None = None
    ended_at: datetime | None = None
    winner_team_number: int | None = None
    participants: list[PlayerMatchParticipantRead] = []


class PlayerEventStatusRead(BaseModel):
    event_id: UUID
    court_id: UUID
    phase: str
    registration: EventRegistrationRead | None = None
    queue_entry: EventQueueEntryRead | None = None
    match: PlayerMatchRead | None = None
    score_submission: ScoreSubmissionRead | None = None
