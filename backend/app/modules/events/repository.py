from sqlalchemy.orm import Session

from app.modules.events.models import Event


class EventRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_id(self, event_id):
        return self.db.get(Event, event_id)
