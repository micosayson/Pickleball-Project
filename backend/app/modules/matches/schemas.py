from pydantic import BaseModel, ConfigDict


class MatchRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    event_id: str
    status: str
