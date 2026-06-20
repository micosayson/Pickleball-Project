from fastapi import APIRouter

router = APIRouter()


@router.get("/")
def dashboard_summary():
    # Minimal demo summary response
    return {
        "courts": 5,
        "active_sessions": 3,
        "queued_players": 28,
        "upcoming_matches": 6,
        "bookings": 4,
    }
