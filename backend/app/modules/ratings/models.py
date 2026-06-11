from sqlalchemy import ForeignKey, Integer, Numeric, String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import AuditMixin, UUIDPrimaryKeyMixin


class Rating(UUIDPrimaryKeyMixin, AuditMixin, Base):
    __tablename__ = "ratings"

    tenant_id: Mapped[str] = mapped_column(ForeignKey("tenants.id", ondelete="RESTRICT"), nullable=False, index=True)
    court_id: Mapped[str | None] = mapped_column(ForeignKey("courts.id", ondelete="RESTRICT"), nullable=True, index=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="RESTRICT"), nullable=False, index=True)
    rating_model: Mapped[str] = mapped_column(String, nullable=False, default="elo")
    rating_value: Mapped[float] = mapped_column(Numeric(10, 2), nullable=False, default=0)
    matches_played: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
