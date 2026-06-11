from sqlalchemy.orm import Session

from app.modules.invitations.models import Invitation


class InvitationRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_id(self, invitation_id):
        return self.db.get(Invitation, invitation_id)
