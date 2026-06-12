from typing import Any, Iterable

from uuid import UUID
from typing import Optional

from sqlalchemy.orm import Session

from app.modules.users.models import User


class UserRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_id(self, user_id: str) -> Optional[User]:
        return self.db.get(User, user_id)

    def get_by_supabase_user_id(self, supabase_user_id: str) -> Optional[User]:
        try:
            supabase_uuid = UUID(supabase_user_id)
        except ValueError:
            return None

        return self.db.query(User).filter_by(supabase_user_id=supabase_uuid).one_or_none()

    def update_profile(
        self,
        user: User,
        full_name: str | None = None,
        avatar_url: str | None = None,
    ) -> User:
        if full_name is not None:
            user.full_name = full_name
        if avatar_url is not None:
            user.avatar_url = avatar_url

        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user

    def get_by_supabase_user_id(self, supabase_user_id: str) -> User | None:
        return self.db.query(User).filter_by(supabase_user_id=supabase_user_id).one_or_none()

    def update_profile(self, user: User, full_name: str | None = None, avatar_url: str | None = None) -> User:
        if full_name is not None:
            user.full_name = full_name
        if avatar_url is not None:
            user.avatar_url = avatar_url

        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user
