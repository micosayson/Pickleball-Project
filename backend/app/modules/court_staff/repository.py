from sqlalchemy.orm import Session

from app.modules.court_staff.models import CourtStaff


class CourtStaffRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_id(self, staff_id):
        return self.db.get(CourtStaff, staff_id)
