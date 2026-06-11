from app.modules.rating_history.repository import RatingHistoryRepository


class RatingHistoryService:
    def __init__(self, repository: RatingHistoryRepository) -> None:
        self.repository = repository
