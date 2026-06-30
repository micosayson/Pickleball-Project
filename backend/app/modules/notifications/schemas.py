from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class NotificationCreate(BaseModel):
    recipient_user_id: UUID
    notification_type: str
    category: str = "general"
    title: str
    body: str
    action_url: str | None = None
    actor_user_id: UUID | None = None
    related_entity_type: str | None = None
    related_entity_id: UUID | None = None
    metadata_json: dict | None = None


class NotificationRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    recipient_user_id: UUID
    actor_user_id: UUID | None = None
    notification_type: str
    category: str
    title: str
    body: str
    action_url: str | None = None
    related_entity_type: str | None = None
    related_entity_id: UUID | None = None
    metadata_json: dict | None = None
    read_at: datetime | None = None
    created_at: datetime
    updated_at: datetime
    read: bool


class NotificationSummaryRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    title: str
    body: str
    read: bool
    created_at: datetime


class NotificationMarkReadResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    read: bool
    read_at: datetime | None = None
