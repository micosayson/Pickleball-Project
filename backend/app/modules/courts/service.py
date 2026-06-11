from app.modules.courts.repository import CourtRepository


class CourtService:
    def __init__(self, repository: CourtRepository) -> None:
        self.repository = repository
