from sqlalchemy.orm import Session

from app.modules.event_participants.models import EventParticipant


class EventParticipantRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_id(self, participant_id):
        return self.db.get(EventParticipant, participant_id)
