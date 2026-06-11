from pydantic import BaseModel, ConfigDict


class RatingHistoryRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    match_id: str
    user_id: str
