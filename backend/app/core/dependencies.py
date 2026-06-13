from uuid import UUID

from fastapi import Depends, Header, HTTPException, status
from sqlalchemy.orm import Session

from app.core.permissions import Role
from app.core.security import Principal, get_current_user_profile
from app.core.tenancy import TenantContext
from app.db.session import get_db
from app.modules.auth.schemas import AuthMeRead
from app.modules.court_memberships.models import CourtMembership
from app.modules.court_staff.models import CourtStaff
from app.modules.courts.models import Court
from app.modules.tenants.models import Tenant
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
    user = UserRepository(db).get_by_supabase_user_id(principal.user_id)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found; sync the authenticated user first",
        )

    is_platform_admin = principal.platform_role == Role.PLATFORM_ADMIN.value
    requested_tenant_id = _normalize_uuid_header(x_tenant_id, "X-Tenant-ID")
    requested_court_id = _normalize_uuid_header(x_court_id, "X-Court-ID")

    if is_platform_admin:
        tenant_id = requested_tenant_id
        if requested_court_id is not None and tenant_id is None:
            court = db.get(Court, UUID(requested_court_id))
            tenant_id = str(court.tenant_id) if court is not None else None
        return TenantContext(
            tenant_id=tenant_id,
            court_id=requested_court_id,
            user_id=principal.user_id,
            backend_user_id=str(user.id),
            platform_role=principal.platform_role,
        )

    owned_tenant_ids = {
        str(row[0])
        for row in db.query(Tenant.id)
        .filter(Tenant.owner_user_id == user.id)
        .all()
    }

    owned_courts = db.query(Court.id, Court.tenant_id).filter(Court.owner_user_id == user.id).all()
    tenant_owned_courts = []
    if owned_tenant_ids:
        tenant_owned_courts = (
            db.query(Court.id, Court.tenant_id)
            .filter(Court.tenant_id.in_([UUID(value) for value in owned_tenant_ids]))
            .all()
        )

    staff_courts = (
        db.query(CourtStaff.court_id, Court.tenant_id)
        .join(Court, Court.id == CourtStaff.court_id)
        .filter(CourtStaff.user_id == user.id, CourtStaff.status == "active")
        .all()
    )
    member_courts = (
        db.query(CourtMembership.court_id, Court.tenant_id)
        .join(Court, Court.id == CourtMembership.court_id)
        .filter(CourtMembership.user_id == user.id, CourtMembership.status == "active")
        .all()
    )

    allowed_court_ids = {str(row[0]) for row in [*owned_courts, *tenant_owned_courts, *staff_courts, *member_courts]}
    allowed_tenant_ids = {
        *owned_tenant_ids,
        *(str(row[1]) for row in [*owned_courts, *tenant_owned_courts, *staff_courts, *member_courts]),
    }

    if requested_tenant_id is not None and requested_tenant_id not in allowed_tenant_ids:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Tenant scope is not available to the current user",
        )
    if requested_court_id is not None and requested_court_id not in allowed_court_ids:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Court scope is not available to the current user",
        )

    tenant_id = requested_tenant_id
    if requested_court_id is not None:
        court = db.get(Court, UUID(requested_court_id))
        tenant_id = str(court.tenant_id) if court is not None else tenant_id

    return TenantContext(
        tenant_id=tenant_id,
        court_id=requested_court_id,
        user_id=principal.user_id,
        backend_user_id=str(user.id),
        platform_role=principal.platform_role,
        allowed_tenant_ids=tuple(sorted(allowed_tenant_ids)),
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
