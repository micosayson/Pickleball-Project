from app.modules.courts.repository import CourtRepository
from app.modules.courts.models import Court


class CourtService:
    def __init__(self, repository: CourtRepository) -> None:
        self.repository = repository

    def list_courts(
        self,
        *,
        status: str | None,
        limit: int,
        offset: int,
    ) -> list[Court]:
        return self.repository.list(status=status, limit=limit, offset=offset)
