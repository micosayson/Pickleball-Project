from fastapi import APIRouter, Depends

from app.core.security import get_current_user_profile
from app.modules.auth.schemas import AuthMeRead

router = APIRouter(tags=["Auth"])


@router.get("/me", response_model=AuthMeRead)
async def me(user: AuthMeRead = Depends(get_current_user_profile)):
    return user
