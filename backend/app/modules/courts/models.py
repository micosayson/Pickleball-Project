from __future__ import annotations

import uuid

from sqlalchemy import ForeignKey, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.db.mixins import AuditMixin, UUIDPrimaryKeyMixin


class Court(UUIDPrimaryKeyMixin, AuditMixin, Base):
    __tablename__ = "courts"
    __table_args__ = (UniqueConstraint("tenant_id", "slug", name="uq_courts_tenant_slug"),)

    tenant_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("tenants.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    name: Mapped[str] = mapped_column(String, nullable=False)
    slug: Mapped[str] = mapped_column(String, nullable=False)
    status: Mapped[str] = mapped_column(String, nullable=False, default="active")

    tenant: Mapped["Tenant"] = relationship("Tenant", back_populates="courts")
    invitations: Mapped[list["Invitation"]] = relationship("Invitation", back_populates="court")
    events: Mapped[list["Event"]] = relationship("Event", back_populates="court")
    court_memberships: Mapped[list["CourtMembership"]] = relationship("CourtMembership", back_populates="court")
    court_staff_assignments: Mapped[list["CourtStaff"]] = relationship("CourtStaff", back_populates="court")
