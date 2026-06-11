from app.modules.match_participants.repository import MatchParticipantRepository


class MatchParticipantService:
    def __init__(self, repository: MatchParticipantRepository) -> None:
        self.repository = repository
