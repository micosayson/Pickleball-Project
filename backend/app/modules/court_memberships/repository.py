from sqlalchemy.orm import Session

from app.modules.court_memberships.models import CourtMembership


class CourtMembershipRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_id(self, membership_id):
        return self.db.get(CourtMembership, membership_id)
