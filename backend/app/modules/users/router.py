from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.core.security import get_current_auth_identity
from app.modules.auth.deps import current_user
from app.modules.auth.schemas import AuthMeRead
from app.modules.users.repository import UserRepository
from app.modules.users.schemas import UserRead, UserSyncRequest, UserUpdate
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


@router.post("/sync", response_model=UserRead)
async def sync_current_user(
    payload: UserSyncRequest,
    user: AuthMeRead = Depends(get_current_auth_identity),
    db: Session = Depends(get_db),
) -> UserRead:
    repository = UserRepository(db)
    synced_user = service.sync_current_user_profile(user, payload, repository)
    print(f"Synced user profile: {synced_user.id} email={synced_user.email}")
    return synced_user
