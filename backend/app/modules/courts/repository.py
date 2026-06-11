from sqlalchemy.orm import Session

from app.modules.courts.models import Court


class CourtRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_id(self, court_id):
        return self.db.get(Court, court_id)
