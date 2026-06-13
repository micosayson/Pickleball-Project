from sqlalchemy.orm import Session

from app.modules.courts.models import Court


class CourtRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def list(
        self,
        *,
        status: str | None = "active",
        limit: int = 50,
        offset: int = 0,
    ) -> list[Court]:
        query = self.db.query(Court)
        if status is not None:
            query = query.filter(Court.status == status)
        return query.order_by(Court.name.asc()).offset(offset).limit(limit).all()

    def get_by_id(self, court_id):
        return self.db.get(Court, court_id)
