from dataclasses import dataclass
from typing import Optional


@dataclass(slots=True)
class TenantContext:
    tenant_id: Optional[str] = None
    court_id: Optional[str] = None
    user_id: Optional[str] = None
    backend_user_id: Optional[str] = None
    platform_role: Optional[str] = None
    allowed_tenant_ids: tuple[str, ...] = ()
    allowed_court_ids: tuple[str, ...] = ()
    owned_court_ids: tuple[str, ...] = ()
    staff_court_ids: tuple[str, ...] = ()
    member_court_ids: tuple[str, ...] = ()

    @property
    def has_scope(self) -> bool:
        return self.tenant_id is not None or self.court_id is not None

    @property
    def is_platform_admin(self) -> bool:
        return self.platform_role == "platform_admin"

    def can_access_tenant(self, tenant_id: str) -> bool:
        return self.is_platform_admin or tenant_id in self.allowed_tenant_ids

    def can_access_court(self, court_id: str) -> bool:
        return self.is_platform_admin or court_id in self.allowed_court_ids

    def can_operate_court(self, court_id: str) -> bool:
        return (
            self.is_platform_admin
            or court_id in self.owned_court_ids
            or court_id in self.staff_court_ids
        )

