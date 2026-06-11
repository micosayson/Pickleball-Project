from app.modules.tenants.repository import TenantRepository


class TenantService:
    def __init__(self, repository: TenantRepository) -> None:
        self.repository = repository
