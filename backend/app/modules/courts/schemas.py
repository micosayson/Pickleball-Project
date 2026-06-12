from pydantic import BaseModel, ConfigDict


class CourtRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    owner_user_id: str
    name: str
    slug: str
    address: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    contact_info: str | None = None
    status: str
