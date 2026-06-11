from app.modules.event_participants.repository import EventParticipantRepository


class EventParticipantService:
    def __init__(self, repository: EventParticipantRepository) -> None:
        self.repository = repository
