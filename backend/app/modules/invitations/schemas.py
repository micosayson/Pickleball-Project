from pydantic import BaseModel, ConfigDict


class InvitationRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    tenant_id: str
    status: str
