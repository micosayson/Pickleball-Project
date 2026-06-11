from pydantic import BaseModel


class PaymentRead(BaseModel):
    id: str
    status: str
