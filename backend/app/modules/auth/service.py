from app.modules.auth.repository import AuthRepository


class AuthService:
    def __init__(self) -> None:
        self.repo = AuthRepository()

    def get_current_user(self, user):
        profile = self.repo.get_user_profile(user.id)
        return {
            "auth": user,
            "profile": profile,
        }
