from app.integrations.supabase.client import supabase


from typing import Any, Mapping

from app.integrations.supabase.client import supabase


class AuthRepository:
    def get_user_profile(self, supabase_user_id: str) -> Mapping[str, Any] | None:
        response = (
            supabase
            .table("users")
            .select("*")
            .eq("supabase_user_id", supabase_user_id)
            .single()
            .execute()
        )
        return response.data

