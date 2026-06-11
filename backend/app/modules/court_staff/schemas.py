from pydantic import BaseModel, ConfigDict


class CourtStaffRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    court_id: str
    user_id: str
    status: str
