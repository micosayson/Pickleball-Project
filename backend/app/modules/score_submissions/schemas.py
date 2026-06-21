from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class ScoreSubmissionCreate(BaseModel):
    match_id: UUID
    team_one_score: int = Field(ge=0)
    team_two_score: int = Field(ge=0)
    notes: str | None = None


class ScoreSubmissionReject(BaseModel):
    dispute_reason: str | None = None


class ScoreSubmissionRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    court_id: UUID
    event_id: UUID
    match_id: UUID
    submitted_by_user_id: UUID
    verified_by_user_id: UUID | None = None
    status: str
    source: str
    team_one_score: int
    team_two_score: int
    submitted_at: datetime
    verified_at: datetime | None = None
    rejected_at: datetime | None = None
    dispute_reason: str | None = None
    notes: str | None = None
