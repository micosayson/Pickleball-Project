from fastapi import APIRouter

from app.api.v1.routes.auth import router as auth_router
from app.api.v1.routes.courts import router as courts_router
from app.api.v1.routes.events import router as events_router
from app.api.v1.routes.invitations import router as invitations_router
from app.api.v1.routes.matches import router as matches_router
from app.api.v1.routes.rankings import router as rankings_router
from app.api.v1.routes.ratings import router as ratings_router
from app.api.v1.routes.test import router as test_router
from app.api.v1.routes.users import router as users_router

api_router = APIRouter()
api_router.include_router(auth_router, prefix="/auth", tags=["auth"])
api_router.include_router(users_router, prefix="/users", tags=["users"])
api_router.include_router(courts_router, prefix="/courts", tags=["courts"])
api_router.include_router(invitations_router, prefix="/invitations", tags=["invitations"])
api_router.include_router(events_router, prefix="/events", tags=["events"])
api_router.include_router(matches_router, prefix="/matches", tags=["matches"])
api_router.include_router(ratings_router, prefix="/ratings", tags=["ratings"])
api_router.include_router(rankings_router, prefix="/rankings", tags=["rankings"])
api_router.include_router(test_router, prefix="/test", tags=["test"])
