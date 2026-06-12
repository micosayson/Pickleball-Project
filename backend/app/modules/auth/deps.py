from fastapi import Depends

from app.core.security import get_current_user_profile, require_role
from app.core.permissions import Role
from app.modules.auth.schemas import AuthMeRead


def current_user(user: AuthMeRead = Depends(get_current_user_profile)) -> AuthMeRead:
    return user


def require_role_dependency(required_roles: list[Role]):
    return require_role(required_roles)
