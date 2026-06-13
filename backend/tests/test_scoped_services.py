from types import SimpleNamespace
from uuid import uuid4

import pytest
from fastapi import HTTPException

from app.db import models as _models  # noqa: F401
from app.core.tenancy import TenantContext
from app.modules.events.schemas import EventUpdate
from app.modules.events.service import EventService
from app.modules.matches.schemas import MatchUpdate
from app.modules.matches.service import MatchService
from app.modules.ratings.schemas import RatingCreate
from app.modules.ratings.service import RatingService
from app.modules.rankings.schemas import RankingCreate
from app.modules.rankings.service import RankingService


class FakeRepository:
    def __init__(self, item=None):
        self.item = item
        self.updated_values = None
        self.created_item = None
        self.list_args = None

    def list(self, scope, **kwargs):
        self.list_args = (scope, kwargs)
        return []

    def get_by_id(self, item_id, scope):
        return self.item

    def create(self, item):
        self.created_item = item
        return item

    def update(self, item, values):
        self.updated_values = values
        for key, value in values.items():
            setattr(item, key, value)
        return item

    def delete(self, item):
        self.item = None


def test_tenant_context_reports_scope():
    assert TenantContext().has_scope is False
    assert TenantContext(court_id=str(uuid4())).has_scope is True
    assert TenantContext(tenant_id=str(uuid4())).has_scope is True


def test_event_update_rejects_cross_court_change():
    repo = FakeRepository(SimpleNamespace(id=uuid4(), court_id=uuid4()))
    service = EventService(repo)
    scope = TenantContext(court_id=str(uuid4()))

    with pytest.raises(HTTPException) as exc:
        service.update_event(uuid4(), EventUpdate(court_id=uuid4()), scope)

    assert exc.value.status_code == 403


def test_match_update_rejects_cross_court_change():
    repo = FakeRepository(SimpleNamespace(id=uuid4(), court_id=uuid4()))
    service = MatchService(repo)
    scope = TenantContext(court_id=str(uuid4()))

    with pytest.raises(HTTPException) as exc:
        service.update_match(uuid4(), MatchUpdate(court_id=uuid4()), scope)

    assert exc.value.status_code == 403


def test_rating_create_uses_court_scope_when_payload_omits_court():
    repo = FakeRepository()
    service = RatingService(repo)
    court_id = uuid4()
    payload = RatingCreate(user_id=uuid4())

    created = service.create_rating(payload, TenantContext(court_id=str(court_id)))

    assert created.court_id == court_id


def test_ranking_create_rejects_cross_court_scope():
    repo = FakeRepository()
    service = RankingService(repo)
    payload = RankingCreate(
        court_id=uuid4(),
        user_id=uuid4(),
        rank_value=1,
        snapshot_at="2026-06-13T00:00:00Z",
    )

    with pytest.raises(HTTPException) as exc:
        service.create_ranking(payload, TenantContext(court_id=str(uuid4())))

    assert exc.value.status_code == 403
