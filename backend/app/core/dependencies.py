from uuid import UUID

from fastapi import Depends, Header, HTTPException, status
from sqlalchemy.exc import ProgrammingError
from sqlalchemy.orm import Session

from app.core.permissions import Role
from app.core.security import Principal, get_current_user_profile
from app.core.tenancy import TenantContext
from app.db.session import get_db
from app.modules.auth.schemas import AuthMeRead
from app.modules.court_memberships.models import CourtMembership
from app.modules.court_staff.models import CourtStaff
from app.modules.courts.models import Court
from app.modules.users.repository import UserRepository


def get_current_principal(user: AuthMeRead = Depends(get_current_user_profile)) -> Principal:
    return Principal(
        user_id=user.user_id,
        email=user.email,
        platform_role=user.platform_role,
    )


def get_tenant_context(
    x_tenant_id: str | None = Header(default=None, alias="X-Tenant-ID"),
    x_court_id: str | None = Header(default=None, alias="X-Court-ID"),
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
) -> TenantContext:
    requested_tenant_id = _normalize_uuid_header(x_tenant_id, "X-Tenant-ID")
    requested_court_id = _normalize_uuid_header(x_court_id, "X-Court-ID")
    user = UserRepository(db).get_by_supabase_user_id(principal.user_id)
    if requested_tenant_id is not None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Tenant scope requires the tenant schema migration",
        )
    if user is None:
        if requested_court_id is not None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User profile not found; sync the authenticated user first",
            )
        return TenantContext(
            user_id=principal.user_id,
            platform_role=principal.platform_role,
        )

    is_platform_admin = principal.platform_role == Role.PLATFORM_ADMIN.value

    try:
        return _resolve_database_tenant_context(
            db=db,
            principal=principal,
            user=user,
            is_platform_admin=is_platform_admin,
            requested_tenant_id=requested_tenant_id,
            requested_court_id=requested_court_id,
        )
    except ProgrammingError:
        db.rollback()
        if requested_tenant_id is not None or requested_court_id is not None:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Tenant schema is not available in the database",
            )
        return TenantContext(
            user_id=principal.user_id,
            backend_user_id=str(user.id),
            platform_role=principal.platform_role,
        )


def _resolve_database_tenant_context(
    *,
    db: Session,
    principal: Principal,
    user,
    is_platform_admin: bool,
    requested_tenant_id: str | None,
    requested_court_id: str | None,
) -> TenantContext:
    if is_platform_admin:
        return TenantContext(
            court_id=requested_court_id,
            user_id=principal.user_id,
            backend_user_id=str(user.id),
            platform_role=principal.platform_role,
        )

    owned_courts = db.query(Court.id).filter(Court.owner_user_id == user.id).all()
    staff_courts = (
        db.query(CourtStaff.court_id)
        .join(Court, Court.id == CourtStaff.court_id)
        .filter(CourtStaff.user_id == user.id, CourtStaff.status == "active")
        .all()
    )
    member_courts = (
        db.query(CourtMembership.court_id)
        .join(Court, Court.id == CourtMembership.court_id)
        .filter(CourtMembership.user_id == user.id, CourtMembership.status == "active")
        .all()
    )

    allowed_court_ids = {str(row[0]) for row in [*owned_courts, *staff_courts, *member_courts]}
    if requested_court_id is not None and requested_court_id not in allowed_court_ids:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Court scope is not available to the current user",
        )

    return TenantContext(
        court_id=requested_court_id,
        user_id=principal.user_id,
        backend_user_id=str(user.id),
        platform_role=principal.platform_role,
        allowed_court_ids=tuple(sorted(allowed_court_ids)),
    )


def _normalize_uuid_header(value: str | None, header_name: str) -> str | None:
    if value is None or value == "":
        return None
    try:
        return str(UUID(value))
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"{header_name} must be a valid UUID",
        ) from exc
