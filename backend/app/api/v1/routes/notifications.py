from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from typing import List

router = APIRouter()


class NotificationItem(BaseModel):
    id: str
    title: str
    body: str
    read: bool


NOTIFICATIONS_DEFERRED_DETAIL = "Notifications are deferred until the notifications backend phase."


@router.get("/", response_model=List[NotificationItem])
def list_notifications():
    raise HTTPException(status_code=status.HTTP_501_NOT_IMPLEMENTED, detail=NOTIFICATIONS_DEFERRED_DETAIL)


@router.post("/{nid}/mark-read")
def mark_read(nid: str):
    raise HTTPException(status_code=status.HTTP_501_NOT_IMPLEMENTED, detail=NOTIFICATIONS_DEFERRED_DETAIL)
