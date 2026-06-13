from uuid import UUID

from pydantic import BaseModel, ConfigDict


class CourtMembershipRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    court_id: UUID
    user_id: UUID
    status: str
