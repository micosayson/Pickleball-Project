from enum import Enum


class PlatformRole(str, Enum):
    PLATFORM_ADMIN = "platform_admin"
    COURT_OWNER = "court_owner"
    STAFF = "staff"
    PLAYER = "player"


class EventType(str, Enum):
    OPEN_PLAY = "open_play"
    COMPETITIVE_PLAY = "competitive_play"


class RecordStatus(str, Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"
    ARCHIVED = "archived"
