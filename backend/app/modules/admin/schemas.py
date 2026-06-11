from pydantic import BaseModel


class AdminRead(BaseModel):
    id: str
