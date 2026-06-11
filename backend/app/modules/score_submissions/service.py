from app.modules.score_submissions.repository import ScoreSubmissionRepository


class ScoreSubmissionService:
    def __init__(self, repository: ScoreSubmissionRepository) -> None:
        self.repository = repository
