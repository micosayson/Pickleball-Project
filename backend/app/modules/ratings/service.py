from uuid import UUID

from fastapi import HTTPException, status

from app.core.tenancy import TenantContext
from app.modules.player_ratings.models import PlayerRating
from app.modules.ratings.repository import RatingRepository
from app.modules.ratings.schemas import RatingCreate, RatingUpdate


class RatingService:
    def __init__(self, repository: RatingRepository) -> None:
        self.repository = repository

    def list_ratings(
        self,
        scope: TenantContext,
        *,
        user_id: UUID | None,
        limit: int,
        offset: int,
    ) -> list[PlayerRating]:
        return self.repository.list(scope, user_id=user_id, limit=limit, offset=offset)

    def get_rating(self, rating_id: UUID, scope: TenantContext) -> PlayerRating:
        rating = self.repository.get_by_id(rating_id, scope)
        if rating is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Rating not found")
        return rating

    def create_rating(self, payload: RatingCreate, scope: TenantContext) -> PlayerRating:
        if scope.court_id and payload.court_id is not None and str(payload.court_id) != scope.court_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Rating court does not match request court scope",
            )
        if scope.tenant_id is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Rating creation requires tenant scope",
            )
        court_id = payload.court_id or (UUID(scope.court_id) if scope.court_id else None)
        return self.repository.create(
            PlayerRating(
                **payload.model_dump(exclude={"court_id"}),
                tenant_id=UUID(scope.tenant_id),
                court_id=court_id,
            )
        )

    def update_rating(self, rating_id: UUID, payload: RatingUpdate, scope: TenantContext) -> PlayerRating:
        rating = self.get_rating(rating_id, scope)
        return self.repository.update(rating, payload.model_dump(exclude_unset=True))

    def delete_rating(self, rating_id: UUID, scope: TenantContext) -> None:
        rating = self.get_rating(rating_id, scope)
        self.repository.delete(rating)
