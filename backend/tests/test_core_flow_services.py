from datetime import UTC, datetime, timedelta
from uuid import uuid4

from sqlalchemy import create_engine
from sqlalchemy.orm import Session

from app.core.tenancy import TenantContext
from app.db import models as _models  # noqa: F401
from app.db.base import Base
from app.modules.courts.models import Court
from app.modules.event_queue.models import EventQueueEntry
from app.modules.event_queue.service import EventQueueService
from app.modules.events.models import Event
from app.modules.match_participants.models import MatchParticipant
from app.modules.matches.models import Match
from app.modules.score_submissions.repository import ScoreSubmissionRepository
from app.modules.score_submissions.schemas import ScoreSubmissionCreate
from app.modules.score_submissions.service import ScoreSubmissionService
from app.modules.users.models import User


def _session() -> Session:
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    return Session(engine, autoflush=False)


def _seed_event(db: Session):
    owner = User(
        supabase_user_id=uuid4(),
        email="owner@example.com",
        platform_role="court_owner",
        status="active",
    )
    players = [
        User(
            supabase_user_id=uuid4(),
            email=f"player{index}@example.com",
            full_name=f"Player {index}",
            platform_role="player",
            status="active",
        )
        for index in range(1, 5)
    ]
    db.add(owner)
    db.add_all(players)
    db.flush()
    court = Court(
        owner_user_id=owner.id,
        name="Test Court",
        slug="test-court",
        status="active",
    )
    db.add(court)
    db.flush()
    event = Event(
        court_id=court.id,
        name="Thursday Competitive Play",
        event_type="competitive_play",
        visibility="public",
        status="published",
        start_at=datetime.now(UTC),
        end_at=datetime.now(UTC) + timedelta(hours=2),
        timezone="UTC",
    )
    db.add(event)
    db.commit()
    return owner, players, court, event


def test_check_in_four_players_creates_doubles_match():
    db = _session()
    _, players, _, event = _seed_event(db)
    service = EventQueueService(db)

    statuses = [
        service.check_in_event(event.id, TenantContext(backend_user_id=str(player.id)))
        for player in players
    ]

    assert statuses[-1].match is not None
    assert statuses[-1].match.match_number == 1
    assert db.query(Match).count() == 1
    assert db.query(MatchParticipant).count() == 4
    assert {
        entry.status for entry in db.query(EventQueueEntry).order_by(EventQueueEntry.checked_in_at).all()
    } == {"assigned"}


def test_score_verification_returns_players_to_queue():
    db = _session()
    owner, players, court, event = _seed_event(db)
    queue_service = EventQueueService(db)
    for player in players:
        queue_service.check_in_event(event.id, TenantContext(backend_user_id=str(player.id)))

    match = db.query(Match).one()
    score_service = ScoreSubmissionService(ScoreSubmissionRepository(db))
    submitted = score_service.create_score_submission(
        ScoreSubmissionCreate(match_id=match.id, team_one_score=11, team_two_score=7),
        TenantContext(backend_user_id=str(players[0].id)),
    )

    verified = score_service.verify_score_submission(
        submitted.id,
        TenantContext(
            backend_user_id=str(owner.id),
            owned_court_ids=(str(court.id),),
            allowed_court_ids=(str(court.id),),
        ),
    )

    assert verified.status == "verified"
    assert db.query(Match).one().status == "verified"
    entries = db.query(EventQueueEntry).order_by(EventQueueEntry.queue_position).all()
    assert [entry.status for entry in entries] == ["queued", "queued", "queued", "queued"]
    assert [entry.assigned_match_id for entry in entries] == [None, None, None, None]
