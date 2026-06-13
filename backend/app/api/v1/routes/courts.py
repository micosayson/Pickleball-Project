from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_principal
from app.core.security import Principal
from app.db.session import get_db
from app.modules.courts.repository import CourtRepository
from app.modules.courts.schemas import CourtRead
from app.modules.courts.service import CourtService

router = APIRouter()


def _service(db: Session) -> CourtService:
    return CourtService(CourtRepository(db))


@router.get("", response_model=list[CourtRead])
def list_courts(
    status: str | None = Query(default="active"),
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    _: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    return _service(db).list_courts(status=status, limit=limit, offset=offset)
