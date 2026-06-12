from pydantic import BaseModel, ConfigDict


class InvitationRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    court_id: str | None = None
    status: str
