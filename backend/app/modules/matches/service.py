from uuid import UUID

from fastapi import HTTPException, status

from app.core.tenancy import TenantContext
from app.modules.matches.models import Match
from app.modules.matches.repository import MatchRepository
from app.modules.matches.schemas import MatchCreate, MatchUpdate


class MatchService:
    def __init__(self, repository: MatchRepository) -> None:
        self.repository = repository

    def list_matches(
        self,
        scope: TenantContext,
        *,
        event_id: UUID | None,
        limit: int,
        offset: int,
    ) -> list[Match]:
        return self.repository.list(scope, event_id=event_id, limit=limit, offset=offset)

    def get_match(self, match_id: UUID, scope: TenantContext) -> Match:
        match = self.repository.get_by_id(match_id, scope)
        if match is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Match not found")
        return match

    def create_match(self, payload: MatchCreate, scope: TenantContext) -> Match:
        if scope.court_id and str(payload.court_id) != scope.court_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Match court does not match request court scope",
            )
        return self.repository.create(Match(**payload.model_dump()))

    def update_match(self, match_id: UUID, payload: MatchUpdate, scope: TenantContext) -> Match:
        match = self.get_match(match_id, scope)
        values = payload.model_dump(exclude_unset=True)
        if scope.court_id and "court_id" in values and str(values["court_id"]) != scope.court_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Match court does not match request court scope",
            )
        return self.repository.update(match, values)

    def delete_match(self, match_id: UUID, scope: TenantContext) -> None:
        match = self.get_match(match_id, scope)
        self.repository.delete(match)
