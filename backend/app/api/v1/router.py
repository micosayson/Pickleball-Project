from fastapi import APIRouter

from app.api.v1.routes import auth, courts, events, invitations, matches, rankings, ratings, test, users

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(courts.router, prefix="/courts", tags=["courts"])
api_router.include_router(invitations.router, prefix="/invitations", tags=["invitations"])
api_router.include_router(events.router, prefix="/events", tags=["events"])
api_router.include_router(matches.router, prefix="/matches", tags=["matches"])
api_router.include_router(ratings.router, prefix="/ratings", tags=["ratings"])
api_router.include_router(rankings.router, prefix="/rankings", tags=["rankings"])
api_router.include_router(test, prefix="/test", tags=["test"])
