from sqlalchemy.orm import Session

from app.modules.matches.models import Match


class MatchRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_id(self, match_id):
        return self.db.get(Match, match_id)
