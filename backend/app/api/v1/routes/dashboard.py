from fastapi import APIRouter, Depends
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.modules.courts.models import Court
from app.modules.event_queue.models import EventQueueEntry
from app.modules.events.models import Event
from app.modules.matches.models import Match

router = APIRouter()


@router.get("/")
def dashboard_summary(db: Session = Depends(get_db)):
    return {
        "courts": _safe_count(
            db,
            db.query(Court).filter(
                Court.status == "active",
                Court.deleted_at.is_(None),
            ),
        ),
        "active_sessions": _safe_count(
            db,
            db.query(Event).filter(
                Event.status.in_(["published", "open", "scheduled", "in_progress"]),
                Event.deleted_at.is_(None),
            ),
        ),
        "queued_players": _safe_count(
            db,
            db.query(EventQueueEntry).filter(
                EventQueueEntry.status == "queued",
                EventQueueEntry.deleted_at.is_(None),
            ),
        ),
        "upcoming_matches": _safe_count(
            db,
            db.query(Match).filter(
                Match.status.in_(["created", "assigned", "scheduled"]),
                Match.deleted_at.is_(None),
            ),
        ),
        "bookings": None,
        "bookings_status": "deferred",
    }


def _safe_count(db: Session, query) -> int | None:
    try:
        return query.count()
    except SQLAlchemyError:
        db.rollback()
        return None
