from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class EventRegistrationRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    court_id: UUID
    event_id: UUID
    user_id: UUID
    status: str
    registered_at: datetime
    checked_in_at: datetime | None = None
    checked_out_at: datetime | None = None
    waitlisted_at: datetime | None = None
    no_show_at: datetime | None = None
    cancelled_at: datetime | None = None
    payment_status: str | None = None
