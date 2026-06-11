from __future__ import annotations

import uuid

from sqlalchemy import ForeignKey, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.db.mixins import AuditMixin, UUIDPrimaryKeyMixin


class CourtStaff(UUIDPrimaryKeyMixin, AuditMixin, Base):
    __tablename__ = "court_staff"
    __table_args__ = (UniqueConstraint("court_id", "user_id", name="uq_court_staff_court_user"),)

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
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    status: Mapped[str] = mapped_column(String, nullable=False, default="active")

    tenant: Mapped["Tenant"] = relationship("Tenant")
    court: Mapped["Court"] = relationship("Court", back_populates="court_staff_assignments")
    user: Mapped["User"] = relationship("User", back_populates="court_staff_assignments", foreign_keys=[user_id])
