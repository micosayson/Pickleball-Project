from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, Numeric, String, UniqueConstraint, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.db.mixins import AuditMixin, UUIDPrimaryKeyMixin


class PlayerRating(UUIDPrimaryKeyMixin, AuditMixin, Base):
    __tablename__ = "player_ratings"
    __table_args__ = (
        UniqueConstraint("tenant_id", "court_id", "user_id", "rating_model", name="uq_player_ratings_scope"),
    )

    tenant_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("tenants.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    court_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("courts.id", ondelete="RESTRICT"),
        nullable=True,
        index=True,
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    rating_model: Mapped[str] = mapped_column(String, nullable=False, default="elo")
    rating_value: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False, default=0)
    rating_deviation: Mapped[float | None] = mapped_column(Numeric(10, 2), nullable=True)
    volatility: Mapped[float | None] = mapped_column(Numeric(10, 4), nullable=True)
    matches_played: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    wins: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    losses: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    last_match_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    last_calculated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    tenant: Mapped["Tenant"] = relationship("Tenant")
    court: Mapped["Court | None"] = relationship("Court")
    user: Mapped["User"] = relationship("User", back_populates="player_ratings", foreign_keys=[user_id])
    history_entries: Mapped[list["RatingHistory"]] = relationship("RatingHistory", back_populates="rating")
    rankings: Mapped[list["Ranking"]] = relationship("Ranking", back_populates="player_rating")
