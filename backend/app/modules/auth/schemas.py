from pydantic import BaseModel, ConfigDict


class AuthMeRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    user_id: str
    email: str | None = None
    platform_role: str | None = None
