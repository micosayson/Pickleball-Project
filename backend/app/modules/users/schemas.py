from uuid import UUID

from pydantic import BaseModel, ConfigDict


class UserRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    email: str
    full_name: str | None = None
    avatar_url: str | None = None
    platform_role: str | None = None
    status: str


class UserUpdate(BaseModel):
    full_name: str | None = None
    avatar_url: str | None = None


class UserSyncRequest(BaseModel):
    full_name: str | None = None
    avatar_url: str | None = None
    platform_role: str | None = None
