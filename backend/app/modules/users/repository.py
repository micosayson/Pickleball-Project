from __future__ import annotations

from uuid import UUID

from sqlalchemy.orm import Session

from app.modules.users.models import User


class UserRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def _parse_supabase_user_id(self, supabase_user_id: str) -> UUID | None:
        try:
            return UUID(supabase_user_id)
        except ValueError:
            return None

    def get_by_supabase_user_id(self, supabase_user_id: str) -> User | None:
        supabase_uuid = self._parse_supabase_user_id(supabase_user_id)
        if supabase_uuid is None:
            return None
        return self.db.query(User).filter_by(supabase_user_id=supabase_uuid).one_or_none()

    def create_or_update_profile(
        self,
        *,
        supabase_user_id: str,
        email: str,
        full_name: str | None = None,
        avatar_url: str | None = None,
        platform_role: str | None = None,
    ) -> User:
        supabase_uuid = self._parse_supabase_user_id(supabase_user_id)
        if supabase_uuid is None:
            raise ValueError("Invalid Supabase user id")

        user = self.get_by_supabase_user_id(supabase_user_id)
        if user is None:
            user = User(
                supabase_user_id=supabase_uuid,
                email=email,
                full_name=full_name,
                avatar_url=avatar_url,
                platform_role=platform_role or "player",
                status="active",
            )
            self.db.add(user)
        else:
            user.email = email
            if full_name is not None:
                user.full_name = full_name
            if avatar_url is not None:
                user.avatar_url = avatar_url
            if platform_role is not None:
                user.platform_role = platform_role

        self.db.commit()
        self.db.refresh(user)
        return user

    def update_profile(self, user: User, full_name: str | None = None, avatar_url: str | None = None) -> User:
        if full_name is not None:
            user.full_name = full_name
        if avatar_url is not None:
            user.avatar_url = avatar_url

        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user
