from app.core.security import Principal


def get_principal_from_supabase_token(token: str) -> Principal:
    raise NotImplementedError("Supabase Auth integration is pending.")
