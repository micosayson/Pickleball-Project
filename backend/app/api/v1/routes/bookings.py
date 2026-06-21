from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import List

router = APIRouter()


class BookingCreate(BaseModel):
    court_id: str
    start_at: str
    end_at: str
    user_id: str


class BookingSummary(BaseModel):
    id: str
    court_id: str
    start_at: str
    end_at: str
    user_id: str
    status: str


BOOKINGS_DEFERRED_DETAIL = "Bookings are deferred until the booking backend phase."


@router.get("/", response_model=List[BookingSummary])
def list_bookings():
    raise HTTPException(status_code=status.HTTP_501_NOT_IMPLEMENTED, detail=BOOKINGS_DEFERRED_DETAIL)


@router.post("/", response_model=BookingSummary)
def create_booking(payload: BookingCreate):
    raise HTTPException(status_code=status.HTTP_501_NOT_IMPLEMENTED, detail=BOOKINGS_DEFERRED_DETAIL)


@router.get("/{booking_id}", response_model=BookingSummary)
def get_booking(booking_id: str):
    raise HTTPException(status_code=status.HTTP_501_NOT_IMPLEMENTED, detail=BOOKINGS_DEFERRED_DETAIL)
