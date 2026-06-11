from pydantic import BaseModel, ConfigDict


class ScoreSubmissionRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    match_id: str
    status: str
