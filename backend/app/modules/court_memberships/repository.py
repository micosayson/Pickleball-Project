from uuid import UUID

from sqlalchemy.orm import Session

from app.core.tenancy import TenantContext
from app.modules.court_memberships.models import CourtMembership
from app.modules.courts.models import Court


class CourtMembershipRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_id(self, membership_id):
        return self.db.get(CourtMembership, membership_id)

    def list_for_user(
        self,
        scope: TenantContext,
        *,
        user_id: UUID,
        limit: int = 50,
        offset: int = 0,
    ) -> list[CourtMembership]:
        query = self.db.query(CourtMembership).filter(
            CourtMembership.user_id == user_id,
            CourtMembership.deleted_at.is_(None),
        )
        if scope.court_id:
            query = query.filter(CourtMembership.court_id == UUID(scope.court_id))
        return (
            query.order_by(CourtMembership.created_at.desc())
            .offset(offset)
            .limit(limit)
            .all()
        )

    def get_court(self, court_id: UUID) -> Court | None:
        return (
            self.db.query(Court)
            .filter(Court.id == court_id, Court.deleted_at.is_(None))
            .one_or_none()
        )

    def get_for_court_user(self, court_id: UUID, user_id: UUID) -> CourtMembership | None:
        return (
            self.db.query(CourtMembership)
            .filter(
                CourtMembership.court_id == court_id,
                CourtMembership.user_id == user_id,
                CourtMembership.deleted_at.is_(None),
            )
            .one_or_none()
        )

    def create(self, membership: CourtMembership) -> CourtMembership:
        self.db.add(membership)
        self.db.commit()
        self.db.refresh(membership)
        return membership

    def update(self, membership: CourtMembership, values: dict) -> CourtMembership:
        for key, value in values.items():
            setattr(membership, key, value)
        self.db.add(membership)
        self.db.commit()
        self.db.refresh(membership)
        return membership
