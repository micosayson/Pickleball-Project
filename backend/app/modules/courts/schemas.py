from uuid import UUID

from pydantic import BaseModel, ConfigDict


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
