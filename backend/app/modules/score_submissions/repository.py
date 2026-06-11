from sqlalchemy.orm import Session

from app.modules.score_submissions.models import ScoreSubmission


class ScoreSubmissionRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_id(self, score_submission_id):
        return self.db.get(ScoreSubmission, score_submission_id)
