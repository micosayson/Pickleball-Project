from app.core.security import Principal
from app.core.tenancy import TenantContext


def get_current_principal() -> Principal:
    raise NotImplementedError("Authentication dependency is pending.")


def get_tenant_context() -> TenantContext:
    raise NotImplementedError("Tenant resolution dependency is pending.")
