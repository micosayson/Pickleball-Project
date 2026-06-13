from datetime import datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class RatingCreate(BaseModel):
    court_id: UUID | None = None
    user_id: UUID
    rating_model: str = "elo"
    rating_value: Decimal = Field(default=Decimal("0"), ge=0)
    rating_deviation: Decimal | None = Field(default=None, ge=0)
    volatility: Decimal | None = Field(default=None, ge=0)
    matches_played: int = Field(default=0, ge=0)
    wins: int = Field(default=0, ge=0)
    losses: int = Field(default=0, ge=0)
    last_match_at: datetime | None = None


class RatingUpdate(BaseModel):
    rating_value: Decimal | None = Field(default=None, ge=0)
    rating_deviation: Decimal | None = Field(default=None, ge=0)
    volatility: Decimal | None = Field(default=None, ge=0)
    matches_played: int | None = Field(default=None, ge=0)
    wins: int | None = Field(default=None, ge=0)
    losses: int | None = Field(default=None, ge=0)
    last_match_at: datetime | None = None


class RatingRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    court_id: UUID | None = None
    user_id: UUID
    rating_model: str
    rating_value: Decimal
    rating_deviation: Decimal | None = None
    volatility: Decimal | None = None
    matches_played: int
    wins: int
    losses: int
    last_match_at: datetime | None = None
    last_calculated_at: datetime
