from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.modules.auth.deps import current_user
from app.modules.auth.schemas import AuthMeRead
from app.modules.users.repository import UserRepository
from app.modules.users.schemas import UserRead, UserUpdate
from app.modules.users.service import UserService

router = APIRouter(tags=["Users"])
service = UserService(UserRepository)


@router.get("/me", response_model=UserRead)
async def read_current_user(user: AuthMeRead = Depends(current_user), db: Session = Depends(get_db)) -> UserRead:
    repository = UserRepository(db)
    return service.get_current_user_profile(user, repository)


@router.patch("/me", response_model=UserRead)
async def update_current_user(
    payload: UserUpdate,
    user: AuthMeRead = Depends(current_user),
    db: Session = Depends(get_db),
) -> UserRead:
    repository = UserRepository(db)
    return service.update_current_user_profile(user, payload, repository)
