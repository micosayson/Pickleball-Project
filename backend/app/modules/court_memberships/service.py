from app.modules.court_memberships.repository import CourtMembershipRepository


class CourtMembershipService:
    def __init__(self, repository: CourtMembershipRepository) -> None:
        self.repository = repository
