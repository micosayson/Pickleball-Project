from fastapi import APIRouter, Depends

from app.api.v1.services.test_service import TestService
from app.modules.auth.deps import current_user, require_role_dependency
from app.modules.auth.schemas import AuthMeRead
from app.core.permissions import Role

router = APIRouter()
service = TestService()


@router.get("/adminOnly", response_model=AuthMeRead)
async def admin_only(user: AuthMeRead = Depends(require_role_dependency([Role.PLATFORM_ADMIN]))):
    return service.get_current_user(user)


@router.get("/court-owner", response_model=AuthMeRead)
async def court_owner(user: AuthMeRead = Depends(require_role_dependency([Role.PLATFORM_ADMIN, Role.COURT_OWNER]))):
    return service.get_current_user(user)


@router.get("/staffOnly", response_model=AuthMeRead)
async def staff_only(user: AuthMeRead = Depends(require_role_dependency([Role.PLATFORM_ADMIN, Role.COURT_OWNER, Role.STAFF]))):
    return service.get_current_user(user)


@router.get("/player", response_model=AuthMeRead)
async def player_only(user: AuthMeRead = Depends(current_user)):
    return service.get_current_user(user)
