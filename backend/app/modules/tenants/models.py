from __future__ import annotations

import uuid

from sqlalchemy import ForeignKey, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.db.mixins import AuditMixin, UUIDPrimaryKeyMixin


class Tenant(UUIDPrimaryKeyMixin, AuditMixin, Base):
    __tablename__ = "tenants"

    name: Mapped[str] = mapped_column(String, nullable=False)
    slug: Mapped[str] = mapped_column(String, unique=True, nullable=False, index=True)
    status: Mapped[str] = mapped_column(String, nullable=False, default="active")
    owner_user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="RESTRICT"),
        nullable=False,
    )

    owner_user: Mapped["User"] = relationship("User", back_populates="owned_tenants", foreign_keys=[owner_user_id])
    courts: Mapped[list["Court"]] = relationship("Court", back_populates="tenant")
    invitations: Mapped[list["Invitation"]] = relationship("Invitation", back_populates="tenant")
    events: Mapped[list["Event"]] = relationship("Event", back_populates="tenant")
