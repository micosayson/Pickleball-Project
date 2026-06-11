from app.modules.invitations.repository import InvitationRepository


class InvitationService:
    def __init__(self, repository: InvitationRepository) -> None:
        self.repository = repository
