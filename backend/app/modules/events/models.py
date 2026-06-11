from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, JSON, String, Text, UniqueConstraint, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.db.mixins import AuditMixin, UUIDPrimaryKeyMixin


class Event(UUIDPrimaryKeyMixin, AuditMixin, Base):
    __tablename__ = "events"
    __table_args__ = (UniqueConstraint("tenant_id", "court_id", "start_at", "name", name="uq_events_schedule"),)

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
    name: Mapped[str] = mapped_column(String, nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    event_type: Mapped[str] = mapped_column(String, nullable=False)
    visibility: Mapped[str] = mapped_column(String, nullable=False, default="public")
    status: Mapped[str] = mapped_column(String, nullable=False, default="draft")
    start_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    end_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    timezone: Mapped[str] = mapped_column(String, nullable=False)
    capacity: Mapped[int | None] = mapped_column(Integer, nullable=True)
    min_players: Mapped[int | None] = mapped_column(Integer, nullable=True)
    max_players: Mapped[int | None] = mapped_column(Integer, nullable=True)
    rules_json: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    check_in_opens_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    check_in_closes_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    tenant: Mapped["Tenant"] = relationship("Tenant", back_populates="events")
    court: Mapped["Court"] = relationship("Court", back_populates="events")
    registrations: Mapped[list["EventRegistration"]] = relationship("EventRegistration", back_populates="event")
    matches: Mapped[list["Match"]] = relationship("Match", back_populates="event")
