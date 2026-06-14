from app.core.tenancy import TenantContext
from app.modules.courts.repository import CourtRepository
from app.modules.courts.models import Court


class CourtService:
    def __init__(self, repository: CourtRepository) -> None:
        self.repository = repository

    def list_courts(
        self,
        *,
        scope: TenantContext | None = None,
        status: str | None,
        limit: int,
        offset: int,
    ) -> list[Court]:
        return self.repository.list(scope=scope, status=status, limit=limit, offset=offset)
