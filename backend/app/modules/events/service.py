from app.modules.events.repository import EventRepository


class EventService:
    def __init__(self, repository: EventRepository) -> None:
        self.repository = repository
