from dataclasses import dataclass
from typing import Optional


@dataclass(slots=True)
class TenantContext:
    tenant_id: Optional[str] = None
    court_id: Optional[str] = None

