from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import List

router = APIRouter()


class PaymentItem(BaseModel):
	id: str
	amount: int
	currency: str
	status: str


PAYMENTS_DEFERRED_DETAIL = "Payments are deferred until the payment backend phase."


@router.get("/", response_model=List[PaymentItem])
def list_payments():
	raise HTTPException(status_code=status.HTTP_501_NOT_IMPLEMENTED, detail=PAYMENTS_DEFERRED_DETAIL)

