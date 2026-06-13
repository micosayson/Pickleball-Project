from dataclasses import dataclass
from typing import Optional


@dataclass(slots=True)
class TenantContext:
    tenant_id: Optional[str] = None
    court_id: Optional[str] = None

    @property
    def has_scope(self) -> bool:
        return self.tenant_id is not None or self.court_id is not None

