from typing import Any, Mapping

from postgrest.exceptions import APIError

from app.integrations.supabase.client import supabase_admin


class AuthRepository:
    def get_user_profile(self, supabase_user_id: str) -> Mapping[str, Any] | None:
        try:
            response = (
                supabase_admin
                .table("users")
                .select("*")
                .eq("supabase_user_id", supabase_user_id)
                .single()
                .execute()
            )
        except APIError as error:
            if error.code == "PGRST116":
                return None
            raise
        return response.data

