from fastapi import APIRouter
from pydantic import BaseModel
from typing import List

router = APIRouter()


class PaymentItem(BaseModel):
	id: str
	amount: int
	currency: str
	status: str


_PAYMENTS = [
	{"id": "p1", "amount": 1000, "currency": "usd", "status": "paid"},
]


@router.get("/", response_model=List[PaymentItem])
def list_payments():
	return _PAYMENTS

