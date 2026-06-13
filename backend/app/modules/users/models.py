from __future__ import annotations

import uuid

from sqlalchemy import String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.db.mixins import AuditMixin, UUIDPrimaryKeyMixin


class User(UUIDPrimaryKeyMixin, AuditMixin, Base):
    __tablename__ = "users"

    supabase_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), unique=True, nullable=False)
    email: Mapped[str] = mapped_column(String, unique=True, nullable=False, index=True)
    full_name: Mapped[str | None] = mapped_column(String, nullable=True)
    avatar_url: Mapped[str | None] = mapped_column(String, nullable=True)
    platform_role: Mapped[str | None] = mapped_column(String, nullable=True)
    status: Mapped[str] = mapped_column(String, nullable=False, default="active")

    owned_courts: Mapped[list["Court"]] = relationship(
        "Court",
        back_populates="owner_user",
        foreign_keys="Court.owner_user_id",
    )
    owned_tenants: Mapped[list["Tenant"]] = relationship(
        "Tenant",
        back_populates="owner_user",
        foreign_keys="Tenant.owner_user_id",
    )
    invitations_sent: Mapped[list["Invitation"]] = relationship(
        "Invitation",
        back_populates="invited_by_user",
        foreign_keys="Invitation.invited_by_user_id",
    )
    invitations_received: Mapped[list["Invitation"]] = relationship(
        "Invitation",
        back_populates="invitee_user",
        foreign_keys="Invitation.invitee_user_id",
    )
    court_memberships: Mapped[list["CourtMembership"]] = relationship(
        "CourtMembership",
        back_populates="user",
        foreign_keys="CourtMembership.user_id",
    )
    court_staff_assignments: Mapped[list["CourtStaff"]] = relationship(
        "CourtStaff",
        back_populates="user",
        foreign_keys="CourtStaff.user_id",
    )
    event_registrations: Mapped[list["EventRegistration"]] = relationship(
        "EventRegistration",
        back_populates="user",
        foreign_keys="EventRegistration.user_id",
    )
    score_submissions_sent: Mapped[list["ScoreSubmission"]] = relationship(
        "ScoreSubmission",
        back_populates="submitted_by_user",
        foreign_keys="ScoreSubmission.submitted_by_user_id",
    )
    score_submissions_verified: Mapped[list["ScoreSubmission"]] = relationship(
        "ScoreSubmission",
        back_populates="verified_by_user",
        foreign_keys="ScoreSubmission.verified_by_user_id",
    )
    player_ratings: Mapped[list["PlayerRating"]] = relationship(
        "PlayerRating",
        back_populates="user",
        foreign_keys="PlayerRating.user_id",
    )
    rating_history_entries: Mapped[list["RatingHistory"]] = relationship(
        "RatingHistory",
        back_populates="user",
        foreign_keys="RatingHistory.user_id",
    )
    rankings: Mapped[list["Ranking"]] = relationship(
        "Ranking",
        back_populates="user",
        foreign_keys="Ranking.user_id",
    )
