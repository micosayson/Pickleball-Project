from typing import Generator

from fastapi import Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.modules.admin.repository import AdminRepository
from app.modules.admin.service import AdminService
from app.modules.court_memberships.repository import CourtMembershipRepository
from app.modules.court_memberships.service import CourtMembershipService
from app.modules.court_staff.repository import CourtStaffRepository
from app.modules.court_staff.service import CourtStaffService
from app.modules.courts.repository import CourtRepository
from app.modules.courts.service import CourtService
from app.modules.event_participants.repository import EventParticipantRepository
from app.modules.event_participants.service import EventParticipantService
from app.modules.events.repository import EventRepository
from app.modules.events.service import EventService
from app.modules.invitations.repository import InvitationRepository
from app.modules.invitations.service import InvitationService
from app.modules.match_participants.repository import MatchParticipantRepository
from app.modules.match_participants.service import MatchParticipantService
from app.modules.matches.repository import MatchRepository
from app.modules.matches.service import MatchService
from app.modules.payments.repository import PaymentRepository
from app.modules.payments.service import PaymentService
from app.modules.rating_history.repository import RatingHistoryRepository
from app.modules.rating_history.service import RatingHistoryService
from app.modules.ratings.repository import RatingRepository
from app.modules.ratings.service import RatingService
from app.modules.rankings.repository import RankingRepository
from app.modules.rankings.service import RankingService
from app.modules.score_submissions.repository import ScoreSubmissionRepository
from app.modules.score_submissions.service import ScoreSubmissionService
from app.modules.tenants.repository import TenantRepository
from app.modules.tenants.service import TenantService
from app.modules.users.repository import UserRepository
from app.modules.users.service import UserService


def provide_session() -> Generator[Session, None, None]:
    yield from get_db()


def provide_user_repository(db: Session = Depends(provide_session)) -> UserRepository:
    return UserRepository(db)


def provide_user_service(repository: UserRepository = Depends(provide_user_repository)) -> UserService:
    return UserService(repository)


def provide_tenant_repository(db: Session = Depends(provide_session)) -> TenantRepository:
    return TenantRepository(db)


def provide_tenant_service(repository: TenantRepository = Depends(provide_tenant_repository)) -> TenantService:
    return TenantService(repository)
