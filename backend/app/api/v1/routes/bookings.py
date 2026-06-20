from fastapi import APIRouter, HTTPException
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


# Simple in-memory store for scaffold/demo purposes
_BOOKINGS: List[dict] = []


@router.get("/", response_model=List[BookingSummary])
def list_bookings():
    return _BOOKINGS


@router.post("/", response_model=BookingSummary)
def create_booking(payload: BookingCreate):
    import uuid

    b = {
        "id": str(uuid.uuid4()),
        "court_id": payload.court_id,
        "start_at": payload.start_at,
        "end_at": payload.end_at,
        "user_id": payload.user_id,
        "status": "confirmed",
    }
    _BOOKINGS.append(b)
    return b


@router.get("/{booking_id}", response_model=BookingSummary)
def get_booking(booking_id: str):
    for b in _BOOKINGS:
        if b["id"] == booking_id:
            return b
    raise HTTPException(status_code=404, detail="Booking not found")
