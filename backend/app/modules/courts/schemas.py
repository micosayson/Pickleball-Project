from pydantic import BaseModel, ConfigDict


class CourtRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    tenant_id: str
    name: str
    slug: str
