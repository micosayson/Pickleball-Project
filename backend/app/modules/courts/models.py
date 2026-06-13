from __future__ import annotations

import uuid
from decimal import Decimal

from sqlalchemy import ForeignKey, String, UniqueConstraint, Numeric, Text
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
    owner_user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    name: Mapped[str] = mapped_column(String, nullable=False)
    slug: Mapped[str] = mapped_column(String, nullable=False, index=True)
    address: Mapped[str | None] = mapped_column(Text, nullable=True)
    latitude: Mapped[Decimal | None] = mapped_column(Numeric(10, 8), nullable=True)
    longitude: Mapped[Decimal | None] = mapped_column(Numeric(11, 8), nullable=True)
    contact_info: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[str] = mapped_column(String, nullable=False, default="active")

    tenant: Mapped["Tenant"] = relationship("Tenant")
    owner_user: Mapped["User"] = relationship("User", back_populates="owned_courts", foreign_keys=[owner_user_id])
    invitations: Mapped[list["Invitation"]] = relationship("Invitation", back_populates="court")
    events: Mapped[list["Event"]] = relationship("Event", back_populates="court")
    court_memberships: Mapped[list["CourtMembership"]] = relationship("CourtMembership", back_populates="court")
    court_staff_assignments: Mapped[list["CourtStaff"]] = relationship("CourtStaff", back_populates="court")
