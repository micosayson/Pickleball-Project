from pydantic import BaseModel


class RatingRead(BaseModel):
    id: str
    rating_value: float
