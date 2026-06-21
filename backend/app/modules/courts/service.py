from uuid import UUID

from fastapi import HTTPException, status

from app.core.tenancy import TenantContext
from app.modules.courts.repository import CourtRepository
from app.modules.courts.models import Court
from app.modules.courts.schemas import CourtCreate, CourtUpdate


class CourtService:
    def __init__(self, repository: CourtRepository) -> None:
        self.repository = repository

    def list_courts(
        self,
        *,
        scope: TenantContext | None = None,
        status: str | None,
        limit: int,
        offset: int,
    ) -> list[Court]:
        return self.repository.list(scope=scope, status=status, limit=limit, offset=offset)

    def get_court(self, court_id: UUID, scope: TenantContext | None = None) -> Court:
        court = self.repository.get_by_id(court_id)
        if court is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Court not found")
        if scope is not None and scope.court_id and str(court.id) != scope.court_id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Court scope mismatch")
        return court

    def create_court(self, payload: CourtCreate, scope: TenantContext) -> Court:
        owner_user_id = payload.owner_user_id
        if owner_user_id is None and scope.backend_user_id is not None:
            owner_user_id = UUID(scope.backend_user_id)
        if owner_user_id is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Court owner is required",
            )
        values = payload.model_dump()
        values["owner_user_id"] = owner_user_id
        return self.repository.create(Court(**values))

    def update_court(self, court_id: UUID, payload: CourtUpdate, scope: TenantContext) -> Court:
        court = self.get_court(court_id, scope)
        if not scope.can_operate_court(str(court.id)):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only court operators can update this court",
            )
        return self.repository.update(court, payload.model_dump(exclude_unset=True))

    def delete_court(self, court_id: UUID, scope: TenantContext) -> None:
        court = self.get_court(court_id, scope)
        if not scope.can_operate_court(str(court.id)):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only court operators can archive this court",
            )
        self.repository.delete(court)
