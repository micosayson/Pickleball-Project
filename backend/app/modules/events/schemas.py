from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class EventBase(BaseModel):
    court_id: UUID
    name: str = Field(min_length=1, max_length=200)
    description: str | None = None
    event_type: str = Field(min_length=1, max_length=80)
    visibility: str = "public"
    status: str = "draft"
    start_at: datetime
    end_at: datetime
    timezone: str = Field(min_length=1, max_length=80)
    capacity: int | None = Field(default=None, ge=1)
    min_players: int | None = Field(default=None, ge=1)
    max_players: int | None = Field(default=None, ge=1)
    rules_json: dict | None = None
    check_in_opens_at: datetime | None = None
    check_in_closes_at: datetime | None = None


class EventCreate(EventBase):
    pass


class EventUpdate(BaseModel):
    court_id: UUID | None = None
    name: str | None = Field(default=None, min_length=1, max_length=200)
    description: str | None = None
    event_type: str | None = Field(default=None, min_length=1, max_length=80)
    visibility: str | None = None
    status: str | None = None
    start_at: datetime | None = None
    end_at: datetime | None = None
    timezone: str | None = Field(default=None, min_length=1, max_length=80)
    capacity: int | None = Field(default=None, ge=1)
    min_players: int | None = Field(default=None, ge=1)
    max_players: int | None = Field(default=None, ge=1)
    rules_json: dict | None = None
    check_in_opens_at: datetime | None = None
    check_in_closes_at: datetime | None = None


class EventRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    court_id: UUID
    name: str
    description: str | None = None
    event_type: str
    visibility: str
    status: str
    start_at: datetime
    end_at: datetime
    timezone: str
    capacity: int | None = None
    min_players: int | None = None
    max_players: int | None = None
    rules_json: dict | None = None
    check_in_opens_at: datetime | None = None
    check_in_closes_at: datetime | None = None
