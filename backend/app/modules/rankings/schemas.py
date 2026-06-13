from datetime import datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class RankingCreate(BaseModel):
    court_id: UUID | None = None
    event_id: UUID | None = None
    user_id: UUID
    player_rating_id: UUID | None = None
    ranking_model: str = "rating_based"
    rank_value: int = Field(ge=1)
    points: Decimal = Field(default=Decimal("0"), ge=0)
    scope_label: str | None = None
    snapshot_at: datetime


class RankingUpdate(BaseModel):
    player_rating_id: UUID | None = None
    rank_value: int | None = Field(default=None, ge=1)
    points: Decimal | None = Field(default=None, ge=0)
    scope_label: str | None = None
    snapshot_at: datetime | None = None


class RankingRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    court_id: UUID | None = None
    event_id: UUID | None = None
    user_id: UUID
    player_rating_id: UUID | None = None
    ranking_model: str
    rank_value: int
    points: Decimal
    scope_label: str | None = None
    snapshot_at: datetime
