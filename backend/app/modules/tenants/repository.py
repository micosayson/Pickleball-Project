from sqlalchemy.orm import Session

from app.modules.tenants.models import Tenant


class TenantRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_id(self, tenant_id):
        return self.db.get(Tenant, tenant_id)
