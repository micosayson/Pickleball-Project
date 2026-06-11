from dataclasses import dataclass
from typing import Optional


@dataclass(slots=True)
class Principal:
    user_id: str
    email: Optional[str] = None
    platform_role: Optional[str] = None


def verify_supabase_token(token: str) -> Principal:
    """Token verification is wired later through Supabase Auth."""
    raise NotImplementedError("Supabase Auth integration is pending.")
