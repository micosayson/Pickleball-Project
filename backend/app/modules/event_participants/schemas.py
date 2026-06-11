from pydantic import BaseModel, ConfigDict


class EventParticipantRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    event_id: str
    user_id: str
    status: str
