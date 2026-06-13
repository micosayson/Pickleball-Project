from uuid import UUID

from sqlalchemy.orm import Session

from app.core.tenancy import TenantContext
from app.modules.player_ratings.models import PlayerRating


class RatingRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def _scoped_query(self, scope: TenantContext):
        query = self.db.query(PlayerRating).filter(PlayerRating.deleted_at.is_(None))
        if scope.court_id:
            query = query.filter(PlayerRating.court_id == UUID(scope.court_id))
        elif scope.tenant_id:
            query = query.filter(PlayerRating.tenant_id == UUID(scope.tenant_id))
        return query

    def list(
        self,
        scope: TenantContext,
        *,
        user_id: UUID | None = None,
        limit: int = 50,
        offset: int = 0,
    ) -> list[PlayerRating]:
        query = self._scoped_query(scope)
        if user_id is not None:
            query = query.filter(PlayerRating.user_id == user_id)
        return (
            query.order_by(PlayerRating.rating_value.desc())
            .offset(offset)
            .limit(limit)
            .all()
        )

    def get_by_id(self, rating_id: UUID, scope: TenantContext) -> PlayerRating | None:
        return self._scoped_query(scope).filter(PlayerRating.id == rating_id).one_or_none()

    def create(self, rating: PlayerRating) -> PlayerRating:
        self.db.add(rating)
        self.db.commit()
        self.db.refresh(rating)
        return rating

    def update(self, rating: PlayerRating, values: dict) -> PlayerRating:
        for key, value in values.items():
            setattr(rating, key, value)
        self.db.add(rating)
        self.db.commit()
        self.db.refresh(rating)
        return rating

    def delete(self, rating: PlayerRating) -> None:
        self.db.delete(rating)
        self.db.commit()
