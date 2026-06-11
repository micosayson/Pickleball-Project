from enum import Enum


class Role(str, Enum):
    PLATFORM_ADMIN = "platform_admin"
    COURT_OWNER = "court_owner"
    STAFF = "staff"
    PLAYER = "player"


class Permission(str, Enum):
    TENANT_MANAGE = "tenant.manage"
    COURT_MANAGE = "court.manage"
    EVENT_MANAGE = "event.manage"
    MATCH_MANAGE = "match.manage"
    SCORE_SUBMIT = "score.submit"
    SCORE_VERIFY = "score.verify"
    RATING_VIEW = "rating.view"
    RATING_RECALCULATE = "rating.recalculate"
    RANKING_VIEW = "ranking.view"
    RANKING_RECALCULATE = "ranking.recalculate"
    PAYMENT_MANAGE = "payment.manage"
