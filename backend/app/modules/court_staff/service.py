from app.modules.court_staff.repository import CourtStaffRepository


class CourtStaffService:
    def __init__(self, repository: CourtStaffRepository) -> None:
        self.repository = repository
