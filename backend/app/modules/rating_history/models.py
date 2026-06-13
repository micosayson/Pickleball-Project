from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Numeric, String, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.db.mixins import AuditMixin, UUIDPrimaryKeyMixin


class RatingHistory(UUIDPrimaryKeyMixin, AuditMixin, Base):
    __tablename__ = "rating_history"
    __table_args__ = (UniqueConstraint("match_id", "rating_id", "user_id", name="uq_rating_history_match_rating_user"),)

    court_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("courts.id", ondelete="RESTRICT"),
        nullable=True,
        index=True,
    )
    event_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("events.id", ondelete="RESTRICT"),
        nullable=True,
        index=True,
    )
    match_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("matches.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    rating_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("player_ratings.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    rating_model: Mapped[str] = mapped_column(String, nullable=False)
    old_rating: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    new_rating: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    delta: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False)
    reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    calculated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    court: Mapped["Court | None"] = relationship("Court")
    event: Mapped["Event | None"] = relationship("Event")
    match: Mapped["Match"] = relationship("Match")
    rating: Mapped["PlayerRating"] = relationship("PlayerRating", back_populates="history_entries")
    user: Mapped["User"] = relationship("User", back_populates="rating_history_entries", foreign_keys=[user_id])
