from uuid import UUID

from fastapi import HTTPException, status

from app.core.tenancy import TenantContext
from app.modules.court_memberships.models import CourtMembership
from app.modules.court_memberships.repository import CourtMembershipRepository


class CourtMembershipService:
    def __init__(self, repository: CourtMembershipRepository) -> None:
        self.repository = repository

    def list_my_memberships(
        self,
        scope: TenantContext,
        *,
        limit: int,
        offset: int,
    ) -> list[CourtMembership]:
        user_id = self._backend_user_id(scope)
        return self.repository.list_for_user(scope, user_id=user_id, limit=limit, offset=offset)

    def join_court(self, court_id: UUID, scope: TenantContext) -> CourtMembership:
        user_id = self._backend_user_id(scope)
        court = self.repository.get_court(court_id)
        if court is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Court not found")
        if court.status != "active":
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Court is not open for membership",
            )

        existing = self.repository.get_for_court_user(court_id, user_id)
        if existing is not None:
            if existing.status != "active":
                return self.repository.update(existing, {"status": "active"})
            return existing

        return self.repository.create(
            CourtMembership(
                court_id=court.id,
                user_id=user_id,
                status="active",
            )
        )

    def leave_court(self, court_id: UUID, scope: TenantContext) -> CourtMembership:
        user_id = self._backend_user_id(scope)
        membership = self.repository.get_for_court_user(court_id, user_id)
        if membership is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Membership not found")
        return self.repository.update(membership, {"status": "cancelled"})

    def _backend_user_id(self, scope: TenantContext) -> UUID:
        if scope.backend_user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Authenticated user profile is required",
            )
        return UUID(scope.backend_user_id)
