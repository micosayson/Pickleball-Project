from sqlalchemy import ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import AuditMixin, UUIDPrimaryKeyMixin


class EventParticipant(UUIDPrimaryKeyMixin, AuditMixin, Base):
    __tablename__ = "event_participants"

    court_id: Mapped[str] = mapped_column(ForeignKey("courts.id", ondelete="RESTRICT"), nullable=False, index=True)
    event_id: Mapped[str] = mapped_column(ForeignKey("events.id", ondelete="RESTRICT"), nullable=False, index=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="RESTRICT"), nullable=False, index=True)
    status: Mapped[str] = mapped_column(String, nullable=False, default="registered")
