from uuid import UUID

from sqlalchemy.orm import Session

from app.core.tenancy import TenantContext
from app.modules.courts.models import Court


class CourtRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def list(
        self,
        *,
        scope: TenantContext | None = None,
        status: str | None = "active",
        limit: int = 50,
        offset: int = 0,
    ) -> list[Court]:
        query = self.db.query(Court)
        if scope is not None:
            if scope.court_id:
                query = query.filter(Court.id == UUID(scope.court_id))
            elif scope.tenant_id:
                query = query.filter(Court.tenant_id == UUID(scope.tenant_id))
        if status is not None:
            query = query.filter(Court.status == status)
        return query.order_by(Court.name.asc()).offset(offset).limit(limit).all()

    def get_by_id(self, court_id):
        return self.db.get(Court, court_id)
