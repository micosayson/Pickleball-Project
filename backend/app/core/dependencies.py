from fastapi import Depends, Header

from app.core.security import Principal, get_current_user_profile
from app.core.tenancy import TenantContext
from app.modules.auth.schemas import AuthMeRead


def get_current_principal(user: AuthMeRead = Depends(get_current_user_profile)) -> Principal:
    return Principal(
        user_id=user.user_id,
        email=user.email,
        platform_role=user.platform_role,
    )


def get_tenant_context(
    x_tenant_id: str | None = Header(default=None, alias="X-Tenant-ID"),
    x_court_id: str | None = Header(default=None, alias="X-Court-ID"),
) -> TenantContext:
    return TenantContext(tenant_id=x_tenant_id, court_id=x_court_id)
