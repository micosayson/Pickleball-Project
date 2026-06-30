from __future__ import annotations

import uuid
from datetime import datetime
from zoneinfo import ZoneInfo

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.modules.court_memberships.models import CourtMembership
from app.modules.court_staff.models import CourtStaff
from app.modules.courts.models import Court
from app.modules.event_registrations.models import EventRegistration
from app.modules.events.models import Event
from app.modules.invitations.models import Invitation
from app.modules.match_participants.models import MatchParticipant
from app.modules.matches.models import Match
from app.modules.notifications.models import Notification
from app.modules.player_ratings.models import PlayerRating
from app.modules.rating_history.models import RatingHistory
from app.modules.rankings.models import Ranking
from app.modules.score_submissions.models import ScoreSubmission
from app.modules.tenants.models import Tenant
from app.modules.users.models import User

DEMO_NAMESPACE = uuid.UUID("6cce2218-5e04-4cda-9b6c-a2d30b0f4f1a")
TAIPEI = ZoneInfo("Asia/Taipei")


def stable_uuid(key: str) -> uuid.UUID:
    return uuid.uuid5(DEMO_NAMESPACE, key)


def get_or_create(session: Session, model, lookup: dict, defaults: dict | None = None):
    instance = session.execute(select(model).filter_by(**lookup)).scalar_one_or_none()
    if instance is not None:
        return instance
    payload = {**lookup, **(defaults or {})}
    instance = model(**payload)
    session.add(instance)
    session.flush()
    return instance


def seed_demo_data(session: Session) -> None:
    event_start = datetime(2026, 6, 18, 18, 0, tzinfo=TAIPEI)
    event_end = datetime(2026, 6, 18, 23, 0, tzinfo=TAIPEI)

    mico = get_or_create(
        session,
        User,
        {"email": "mico@example.com"},
        {
            "supabase_user_id": stable_uuid("user:mico"),
            "full_name": "Mico",
            "platform_role": "platform_admin",
            "status": "active",
        },
    )

    staff_1 = get_or_create(
        session,
        User,
        {"email": "staff1@example.com"},
        {
            "supabase_user_id": stable_uuid("user:staff-1"),
            "full_name": "Staff 1",
            "platform_role": "staff",
            "status": "active",
        },
    )

    player_a = get_or_create(
        session,
        User,
        {"email": "player-a@example.com"},
        {
            "supabase_user_id": stable_uuid("user:player-a"),
            "full_name": "Player A",
            "platform_role": "player",
            "status": "active",
        },
    )
    player_b = get_or_create(
        session,
        User,
        {"email": "player-b@example.com"},
        {
            "supabase_user_id": stable_uuid("user:player-b"),
            "full_name": "Player B",
            "platform_role": "player",
            "status": "active",
        },
    )
    player_c = get_or_create(
        session,
        User,
        {"email": "player-c@example.com"},
        {
            "supabase_user_id": stable_uuid("user:player-c"),
            "full_name": "Player C",
            "platform_role": "player",
            "status": "active",
        },
    )
    player_d = get_or_create(
        session,
        User,
        {"email": "player-d@example.com"},
        {
            "supabase_user_id": stable_uuid("user:player-d"),
            "full_name": "Player D",
            "platform_role": "player",
            "status": "active",
        },
    )

    tenant = get_or_create(
        session,
        Tenant,
        {"slug": "smash-zone"},
        {
            "name": "Smash Zone",
            "status": "active",
            "owner_user_id": mico.id,
        },
    )

    test_court = get_or_create(
        session,
        Court,
        {"tenant_id": tenant.id, "slug": "test-court"},
        {
            "name": "Test Court",
            "status": "active",
        },
    )
    smash_zone = get_or_create(
        session,
        Court,
        {"tenant_id": tenant.id, "slug": "smash-zone-main"},
        {
            "name": "Smash Zone",
            "status": "active",
        },
    )

    for player in (player_a, player_b, player_c, player_d):
        get_or_create(
            session,
            CourtMembership,
            {"court_id": smash_zone.id, "user_id": player.id},
            {
                "tenant_id": tenant.id,
                "status": "active",
            },
        )

    get_or_create(
        session,
        CourtStaff,
        {"court_id": smash_zone.id, "user_id": staff_1.id},
        {
            "tenant_id": tenant.id,
            "status": "active",
        },
    )

    get_or_create(
        session,
        Invitation,
        {"tenant_id": tenant.id, "invitee_email": "staff1@example.com", "token": "seed-staff-1"},
        {
            "court_id": test_court.id,
            "invited_by_user_id": mico.id,
            "invitee_user_id": staff_1.id,
            "invite_role": "staff",
            "status": "accepted",
            "expires_at": event_start,
            "accepted_at": event_start,
            "declined_at": None,
        },
    )
    event = get_or_create(
        session,
        Event,
        {"tenant_id": tenant.id, "court_id": smash_zone.id, "name": "Thursday Competitive Play"},
        {
            "status": "in_progress",
            "event_type": "competitive_play",
            "visibility": "public",
            "start_at": event_start,
            "end_at": event_end,
            "timezone": "Asia/Taipei",
            "capacity": 40,
            "min_players": 4,
            "max_players": 40,
            "rules_json": {"format": "doubles", "auto_rotation": True},
            "check_in_opens_at": event_start,
            "check_in_closes_at": event_end,
        },
    )

    for player in (player_a, player_b, player_c, player_d):
        get_or_create(
            session,
            EventRegistration,
            {"event_id": event.id, "user_id": player.id},
            {
                "tenant_id": tenant.id,
                "court_id": smash_zone.id,
                "status": "checked_in",
                "registered_at": event_start,
                "checked_in_at": event_start,
                "payment_status": "waived",
            },
        )

    match = get_or_create(
        session,
        Match,
        {"event_id": event.id, "match_number": 1},
        {
            "tenant_id": tenant.id,
            "court_id": smash_zone.id,
            "match_type": "doubles",
            "status": "completed",
            "round_number": 1,
            "scheduled_at": event_start,
            "started_at": event_start,
            "ended_at": event_start.replace(hour=19, minute=0),
            "duration_seconds": 3600,
            "winner_team_number": 1,
            "notes": "Seed match for testing ratings and rankings.",
        },
    )

    match_entries = [
        (player_a, 1, 1),
        (player_b, 1, 2),
        (player_c, 2, 1),
        (player_d, 2, 2),
    ]
    for player, team_number, slot_number in match_entries:
        get_or_create(
            session,
            MatchParticipant,
            {"match_id": match.id, "user_id": player.id},
            {
                "tenant_id": tenant.id,
                "team_number": team_number,
                "slot_number": slot_number,
                "role": "player",
                "status": "active",
            },
        )

    get_or_create(
        session,
        ScoreSubmission,
        {"match_id": match.id, "submitted_by_user_id": staff_1.id},
        {
            "tenant_id": tenant.id,
            "court_id": smash_zone.id,
            "event_id": event.id,
            "status": "verified",
            "source": "staff",
            "team_one_score": 11,
            "team_two_score": 8,
            "submitted_at": event_start.replace(hour=19, minute=5),
            "verified_at": event_start.replace(hour=19, minute=6),
            "rejected_at": None,
            "dispute_reason": None,
            "notes": "Seed score for demo testing.",
            "verified_by_user_id": staff_1.id,
        },
    )

    rating_values = {
        player_a.id: 3.55,
        player_b.id: 3.43,
        player_c.id: 3.58,
        player_d.id: 3.45,
    }

    ratings = {}
    for player in (player_a, player_b, player_c, player_d):
        ratings[player.id] = get_or_create(
            session,
            PlayerRating,
            {"tenant_id": tenant.id, "user_id": player.id, "rating_model": "elo", "court_id": None},
            {
                "rating_value": rating_values[player.id],
                "rating_deviation": 0.25,
                "volatility": 0.06,
                "matches_played": 1,
                "wins": 1 if player.id in {player_a.id, player_b.id} else 0,
                "losses": 1 if player.id in {player_c.id, player_d.id} else 0,
                "last_match_at": event_start.replace(hour=19, minute=0),
                "last_calculated_at": event_start.replace(hour=19, minute=6),
            },
        )

    history_rows = [
        (player_a, 3.52, 3.55, 0.03, "Match 1 rating update"),
        (player_b, 3.40, 3.43, 0.03, "Match 1 rating update"),
        (player_c, 3.61, 3.58, -0.03, "Match 1 rating update"),
        (player_d, 3.48, 3.45, -0.03, "Match 1 rating update"),
    ]
    for player, old_rating, new_rating, delta, reason in history_rows:
        get_or_create(
            session,
            RatingHistory,
            {"match_id": match.id, "rating_id": ratings[player.id].id, "user_id": player.id},
            {
                "tenant_id": tenant.id,
                "court_id": smash_zone.id,
                "event_id": event.id,
                "rating_model": "elo",
                "old_rating": old_rating,
                "new_rating": new_rating,
                "delta": delta,
                "reason": reason,
                "calculated_at": event_start.replace(hour=19, minute=6),
            },
        )

    ranking_values = {
        player_a.id: (1, 3.55),
        player_b.id: (2, 3.43),
        player_c.id: (3, 3.58),
        player_d.id: (4, 3.45),
    }
    for player in (player_a, player_b, player_c, player_d):
        rank_value, points = ranking_values[player.id]
        get_or_create(
            session,
            Ranking,
            {
                "tenant_id": tenant.id,
                "user_id": player.id,
                "ranking_model": "rating_based",
                "court_id": None,
                "event_id": None,
            },
            {
                "rank_value": rank_value,
                "points": points,
                "scope_label": "global",
                "snapshot_at": event_start.replace(hour=19, minute=6),
                "player_rating_id": ratings[player.id].id,
            },
        )

    notification_rows = [
        (
            "notification:mico:match-verified",
            mico,
            staff_1,
            "match_alert",
            "match",
            "Match verified",
            "Your latest match was verified and your ranking was updated.",
            "/player/matches/%s" % match.id,
            "match",
            match.id,
            {"match_number": match.match_number, "winner_team_number": 1},
        ),
        (
            "notification:mico:friend-request",
            mico,
            player_a,
            "friend_request",
            "social",
            "New friend request",
            "Player A sent you a friend request.",
            "/player/social/friends",
            None,
            None,
            {"requester_name": "Player A"},
        ),
        (
            "notification:mico:message",
            mico,
            player_b,
            "message",
            "message",
            "Message from Player B",
            "Hey Mico, can we play again this weekend?",
            "/player/messages",
            None,
            None,
            {"sender_name": "Player B", "preview": "Hey Mico, can we play again this weekend?"},
        ),
        (
            "notification:player-a:rating-update",
            player_a,
            None,
            "rating_update",
            "rating",
            "Your rating changed",
            "Your rating moved up by 0.03 to 3.55.",
            "/player/profile/history",
            "rating_history",
            None,
            {"old_rating": 3.52, "new_rating": 3.55, "delta": 0.03},
        ),
    ]

    for key, recipient, actor, notification_type, category, title, body, action_url, entity_type, entity_id, metadata in notification_rows:
        get_or_create(
            session,
            Notification,
            {"id": stable_uuid(key)},
            {
                "recipient_user_id": recipient.id,
                "actor_user_id": None if actor is None else actor.id,
                "notification_type": notification_type,
                "category": category,
                "title": title,
                "body": body,
                "action_url": action_url,
                "related_entity_type": entity_type,
                "related_entity_id": entity_id,
                "metadata_json": metadata,
                "read_at": None,
            },
        )

    session.flush()


def run_system_seeding(session: Session) -> None:
    seed_demo_data(session)
