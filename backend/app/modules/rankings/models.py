from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, Numeric, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.db.mixins import AuditMixin, UUIDPrimaryKeyMixin


class Ranking(UUIDPrimaryKeyMixin, AuditMixin, Base):
    __tablename__ = "rankings"
    __table_args__ = (
        UniqueConstraint(
            "tenant_id",
            "court_id",
            "event_id",
            "user_id",
            "ranking_model",
            name="uq_rankings_scope",
        ),
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
    event_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("events.id", ondelete="RESTRICT"),
        nullable=True,
        index=True,
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    player_rating_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("player_ratings.id", ondelete="RESTRICT"),
        nullable=True,
        index=True,
    )
    ranking_model: Mapped[str] = mapped_column(String, nullable=False, default="rating_based")
    rank_value: Mapped[int] = mapped_column(Integer, nullable=False)
    points: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False, default=0)
    scope_label: Mapped[str | None] = mapped_column(String, nullable=True)
    snapshot_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    court: Mapped["Court | None"] = relationship("Court")
    event: Mapped["Event | None"] = relationship("Event")
    user: Mapped["User"] = relationship("User", back_populates="rankings", foreign_keys=[user_id])
    player_rating: Mapped["PlayerRating | None"] = relationship("PlayerRating", back_populates="rankings")
