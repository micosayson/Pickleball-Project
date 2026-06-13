from uuid import UUID

from fastapi import HTTPException, status

from app.core.tenancy import TenantContext
from app.modules.rankings.models import Ranking
from app.modules.rankings.repository import RankingRepository
from app.modules.rankings.schemas import RankingCreate, RankingUpdate


class RankingService:
    def __init__(self, repository: RankingRepository) -> None:
        self.repository = repository

    def list_rankings(
        self,
        scope: TenantContext,
        *,
        event_id: UUID | None,
        user_id: UUID | None,
        limit: int,
        offset: int,
    ) -> list[Ranking]:
        return self.repository.list(
            scope,
            event_id=event_id,
            user_id=user_id,
            limit=limit,
            offset=offset,
        )

    def get_ranking(self, ranking_id: UUID, scope: TenantContext) -> Ranking:
        ranking = self.repository.get_by_id(ranking_id, scope)
        if ranking is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Ranking not found")
        return ranking

    def create_ranking(self, payload: RankingCreate, scope: TenantContext) -> Ranking:
        if scope.court_id and payload.court_id is not None and str(payload.court_id) != scope.court_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Ranking court does not match request court scope",
            )
        court_id = payload.court_id or (UUID(scope.court_id) if scope.court_id else None)
        return self.repository.create(
            Ranking(**payload.model_dump(exclude={"court_id"}), court_id=court_id)
        )

    def update_ranking(self, ranking_id: UUID, payload: RankingUpdate, scope: TenantContext) -> Ranking:
        ranking = self.get_ranking(ranking_id, scope)
        return self.repository.update(ranking, payload.model_dump(exclude_unset=True))

    def delete_ranking(self, ranking_id: UUID, scope: TenantContext) -> None:
        ranking = self.get_ranking(ranking_id, scope)
        self.repository.delete(ranking)
