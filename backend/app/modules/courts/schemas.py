from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class CourtCreate(BaseModel):
    owner_user_id: UUID | None = None
    name: str = Field(min_length=1, max_length=200)
    slug: str = Field(min_length=1, max_length=120)
    address: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    contact_info: str | None = None
    status: str = "active"


class CourtUpdate(BaseModel):
    owner_user_id: UUID | None = None
    name: str | None = Field(default=None, min_length=1, max_length=200)
    slug: str | None = Field(default=None, min_length=1, max_length=120)
    address: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    contact_info: str | None = None
    status: str | None = None


class CourtRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    owner_user_id: UUID | None = None
    name: str
    slug: str
    address: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    contact_info: str | None = None
    status: str
