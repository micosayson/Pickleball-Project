from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class MatchBase(BaseModel):
    court_id: UUID
    event_id: UUID
    match_number: int = Field(ge=1)
    round_number: int | None = Field(default=None, ge=1)
    match_type: str = Field(min_length=1, max_length=80)
    status: str = "created"
    scheduled_at: datetime | None = None
    started_at: datetime | None = None
    ended_at: datetime | None = None
    duration_seconds: int | None = Field(default=None, ge=0)
    winner_team_number: int | None = Field(default=None, ge=1)
    notes: str | None = None


class MatchCreate(MatchBase):
    tenant_id: UUID | None = None


class MatchUpdate(BaseModel):
    court_id: UUID | None = None
    event_id: UUID | None = None
    match_number: int | None = Field(default=None, ge=1)
    round_number: int | None = Field(default=None, ge=1)
    match_type: str | None = Field(default=None, min_length=1, max_length=80)
    status: str | None = None
    scheduled_at: datetime | None = None
    started_at: datetime | None = None
    ended_at: datetime | None = None
    duration_seconds: int | None = Field(default=None, ge=0)
    winner_team_number: int | None = Field(default=None, ge=1)
    notes: str | None = None


class MatchRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    tenant_id: UUID
    court_id: UUID
    event_id: UUID
    match_number: int
    round_number: int | None = None
    match_type: str
    status: str
    scheduled_at: datetime | None = None
    started_at: datetime | None = None
    ended_at: datetime | None = None
    duration_seconds: int | None = None
    winner_team_number: int | None = None
    notes: str | None = None
