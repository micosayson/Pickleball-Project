from app.modules.auth.schemas import AuthMeRead


class TestService:
    def get_current_user(self, user: AuthMeRead) -> AuthMeRead:
        return user
