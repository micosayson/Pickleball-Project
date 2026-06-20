from fastapi import APIRouter
from pydantic import BaseModel
from typing import List

router = APIRouter()


class NotificationItem(BaseModel):
    id: str
    title: str
    body: str
    read: bool


# In-memory demo notifications
_NOTIFICATIONS = [
    {"id": "1", "title": "Match Ready", "body": "Your match is ready.", "read": False},
    {"id": "2", "title": "Payment Received", "body": "Payment confirmed.", "read": True},
]


@router.get("/", response_model=List[NotificationItem])
def list_notifications():
    return _NOTIFICATIONS


@router.post("/{nid}/mark-read")
def mark_read(nid: str):
    for n in _NOTIFICATIONS:
        if n["id"] == nid:
            n["read"] = True
            return {"ok": True}
    return {"ok": False}
