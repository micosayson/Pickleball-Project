from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, String, Text, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.db.mixins import AuditMixin, UUIDPrimaryKeyMixin


class ScoreSubmission(UUIDPrimaryKeyMixin, AuditMixin, Base):
    __tablename__ = "score_submissions"

    tenant_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("tenants.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    court_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("courts.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    event_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("events.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    match_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("matches.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    submitted_by_user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="RESTRICT"),
        nullable=False,
    )
    verified_by_user_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="RESTRICT"),
        nullable=True,
    )
    status: Mapped[str] = mapped_column(String, nullable=False, default="pending")
    source: Mapped[str] = mapped_column(String, nullable=False, default="staff")
    team_one_score: Mapped[int] = mapped_column(Integer, nullable=False)
    team_two_score: Mapped[int] = mapped_column(Integer, nullable=False)
    submitted_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    verified_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    rejected_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    dispute_reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)

    court: Mapped["Court"] = relationship("Court")
    event: Mapped["Event"] = relationship("Event")
    match: Mapped["Match"] = relationship("Match", back_populates="score_submissions")
    submitted_by_user: Mapped["User"] = relationship(
        "User",
        back_populates="score_submissions_sent",
        foreign_keys=[submitted_by_user_id],
    )
    verified_by_user: Mapped["User | None"] = relationship(
        "User",
        back_populates="score_submissions_verified",
        foreign_keys=[verified_by_user_id],
    )
