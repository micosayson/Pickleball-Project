from sqlalchemy.orm import Session

from app.modules.rating_history.models import RatingHistory


class RatingHistoryRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_id(self, history_id):
        return self.db.get(RatingHistory, history_id)
