from app.modules.matches.repository import MatchRepository


class MatchService:
    def __init__(self, repository: MatchRepository) -> None:
        self.repository = repository
