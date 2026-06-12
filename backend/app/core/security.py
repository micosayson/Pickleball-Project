from typing import Any, Mapping, Optional, cast

from fastapi import Header, HTTPException, Depends, status
from app.integrations.supabase.client import supabase
from app.modules.auth.schemas import AuthMeRead
from app.modules.auth.repository import AuthRepository
from app.core.permissions import Role


async def get_current_token(authorization: str = Header(...)):
    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
        )
    token = authorization.split(" ", 1)[1]
    return token


def verify_supabase_jwt(token: str) -> Mapping[str, Any]:
    try:
        claims_response = supabase.auth.get_claims(token)
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid token: {exc}",
        )

    claims = getattr(claims_response, "claims", None)
    if claims is None:
        get_method = getattr(claims_response, "get", None)
        if callable(get_method):
            claims = get_method("claims")

    if not isinstance(claims, Mapping):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token claims",
        )

    return cast(Mapping[str, Any], claims)


def get_current_user_profile(token: str = Depends(get_current_token)) -> AuthMeRead:
    claims = verify_supabase_jwt(token)
    user_id = claims.get("sub")
    email = claims.get("email")

    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token does not contain user id",
        )

    profile: Optional[Mapping[str, Any]] = AuthRepository().get_user_profile(user_id)
    platform_role = None
    if isinstance(profile, Mapping):
        platform_role = profile.get("platform_role") or profile.get("role")

    return AuthMeRead(
        user_id=str(user_id),
        email=str(email) if email is not None else None,
        platform_role=str(platform_role) if platform_role is not None else None,
    )


def get_current_auth_identity(token: str = Depends(get_current_token)) -> AuthMeRead:
    claims = verify_supabase_jwt(token)
    user_id = claims.get("sub")
    email = claims.get("email")

    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token does not contain user id",
        )

    return AuthMeRead(
        user_id=str(user_id),
        email=str(email) if email is not None else None,
        platform_role=None,
    )


def require_role(required_roles: list[Role]):
    def dependency(user: AuthMeRead = Depends(get_current_user_profile)) -> AuthMeRead:
        if user.platform_role not in [role.value for role in required_roles]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions",
            )
        return user

    return dependency
