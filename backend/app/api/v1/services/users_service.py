from typing import Optional
from app.modules.auth.schemas import AuthMeRead
from app.modules.users.repository import UserRepository
from app.modules.users.schemas import UserRead, UserUpdate
from app.modules.users.models import User


class UserService:
    def __init__(self, repository: type[UserRepository]) -> None:
        self.repository_class = repository

    def get_current_user_profile(self, user: AuthMeRead, repository: UserRepository) -> UserRead:
        user_model = repository.get_by_supabase_user_id(user.user_id)
        if not user_model:
            raise ValueError("User profile not found")

        return UserRead.from_orm(user_model)

    def update_current_user_profile(
        self,
        user: AuthMeRead,
        payload: UserUpdate,
        repository: UserRepository,
    ) -> UserRead:
        user_model = repository.get_by_supabase_user_id(user.user_id)
        if not user_model:
            raise ValueError("User profile not found")

        updated = repository.update_profile(user_model, payload)
        if not updated:
            raise ValueError("Failed to update user profile")

        return UserRead.from_orm(user_model)
