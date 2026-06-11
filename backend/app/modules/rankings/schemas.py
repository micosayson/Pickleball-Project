from pydantic import BaseModel


class RankingRead(BaseModel):
    id: str
    rank_value: int
