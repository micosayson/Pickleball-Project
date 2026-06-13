from uuid import UUID

from sqlalchemy.orm import Session

from app.core.tenancy import TenantContext
from app.modules.rankings.models import Ranking


class RankingRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def _scoped_query(self, scope: TenantContext):
        query = self.db.query(Ranking).filter(Ranking.deleted_at.is_(None))
        if scope.court_id:
            query = query.filter(Ranking.court_id == UUID(scope.court_id))
        elif scope.tenant_id:
            query = query.filter(Ranking.tenant_id == UUID(scope.tenant_id))
        return query

    def list(
        self,
        scope: TenantContext,
        *,
        event_id: UUID | None = None,
        user_id: UUID | None = None,
        limit: int = 50,
        offset: int = 0,
    ) -> list[Ranking]:
        query = self._scoped_query(scope)
        if event_id is not None:
            query = query.filter(Ranking.event_id == event_id)
        if user_id is not None:
            query = query.filter(Ranking.user_id == user_id)
        return (
            query.order_by(Ranking.rank_value.asc())
            .offset(offset)
            .limit(limit)
            .all()
        )

    def get_by_id(self, ranking_id: UUID, scope: TenantContext) -> Ranking | None:
        return self._scoped_query(scope).filter(Ranking.id == ranking_id).one_or_none()

    def create(self, ranking: Ranking) -> Ranking:
        self.db.add(ranking)
        self.db.commit()
        self.db.refresh(ranking)
        return ranking

    def update(self, ranking: Ranking, values: dict) -> Ranking:
        for key, value in values.items():
            setattr(ranking, key, value)
        self.db.add(ranking)
        self.db.commit()
        self.db.refresh(ranking)
        return ranking

    def delete(self, ranking: Ranking) -> None:
        self.db.delete(ranking)
        self.db.commit()
