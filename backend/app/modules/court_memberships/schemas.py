from pydantic import BaseModel, ConfigDict


class CourtMembershipRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    court_id: str
    user_id: str
    status: str
