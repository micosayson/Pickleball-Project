from uuid import UUID

from sqlalchemy.orm import Session

from app.core.tenancy import TenantContext
from app.modules.matches.models import Match


class MatchRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def _scoped_query(self, scope: TenantContext):
        query = self.db.query(Match).filter(Match.deleted_at.is_(None))
        if scope.court_id:
            query = query.filter(Match.court_id == UUID(scope.court_id))
        elif scope.tenant_id:
            query = query.filter(Match.tenant_id == UUID(scope.tenant_id))
        return query

    def list(
        self,
        scope: TenantContext,
        *,
        event_id: UUID | None = None,
        limit: int = 50,
        offset: int = 0,
    ) -> list[Match]:
        query = self._scoped_query(scope)
        if event_id is not None:
            query = query.filter(Match.event_id == event_id)
        return (
            query.order_by(Match.event_id.asc(), Match.match_number.asc())
            .offset(offset)
            .limit(limit)
            .all()
        )

    def get_by_id(self, match_id: UUID, scope: TenantContext) -> Match | None:
        return self._scoped_query(scope).filter(Match.id == match_id).one_or_none()

    def create(self, match: Match) -> Match:
        self.db.add(match)
        self.db.commit()
        self.db.refresh(match)
        return match

    def update(self, match: Match, values: dict) -> Match:
        for key, value in values.items():
            setattr(match, key, value)
        self.db.add(match)
        self.db.commit()
        self.db.refresh(match)
        return match

    def delete(self, match: Match) -> None:
        self.db.delete(match)
        self.db.commit()
