from sqlalchemy.orm import Session

from app.modules.match_participants.models import MatchParticipant


class MatchParticipantRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_id(self, participant_id):
        return self.db.get(MatchParticipant, participant_id)
