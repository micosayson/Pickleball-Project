from fastapi import HTTPException, status
from app.modules.auth.schemas import AuthMeRead
from app.modules.users.repository import UserRepository
from app.modules.users.schemas import UserRead, UserUpdate


class UserService:
    def __init__(self, repository: type[UserRepository]) -> None:
        self.repository_class = repository

    def get_current_user_profile(self, user: AuthMeRead, repository: UserRepository) -> UserRead:
        user_model = repository.get_by_supabase_user_id(user.user_id)
        if not user_model:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User profile not found",
            )

        return UserRead.from_orm(user_model)

    def update_current_user_profile(
        self,
        user: AuthMeRead,
        payload: UserUpdate,
        repository: UserRepository,
    ) -> UserRead:
        user_model = repository.get_by_supabase_user_id(user.user_id)
        if not user_model:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User profile not found",
            )

        updated_user = repository.update_profile(
            user_model,
            full_name=payload.full_name,
            avatar_url=payload.avatar_url,
        )

        return UserRead.from_orm(updated_user)
