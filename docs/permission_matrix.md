# Permission Matrix

This matrix defines the default access model for the pickleball platform.

Principles:

- `Platform Admin` has platform-wide oversight
- `Court Owner` is tenant-scoped
- `Staff` is court-scoped or event-scoped operational access
- `Player` is self-scoped participation access
- all sensitive actions must respect tenant and court isolation
- derived data such as ratings and rankings should not be manually edited outside controlled admin workflows

## Module Access

| Module | Platform Admin | Court Owner | Staff | Player |
|---|---:|---:|---:|---:|
| Users | Full | Tenant scope | Assigned scope | Self only |
| Courts | Full | Own tenant | Assigned court view | Public discovery only |
| Court Memberships | Full | Own tenant | Assigned court view | Self only |
| Court Staff | Full | Own tenant | Self/assigned view | None |
| Invitations | Full | Own tenant | Assigned court scope | Own invite only |
| Events | Full | Own tenant | Assigned events | Public/joined scope |
| Event Participants | Full | Own tenant | Assigned event scope | Self only |
| Matches | Full | Own tenant | Assigned event scope | Own participation only |
| Match Participants | Full | Own tenant | Assigned event scope | Self only |
| Score Submissions | Full | Own tenant | Assigned event scope | Self submit only if allowed |
| Ratings | Full | Tenant/global scope | View-only assigned scope | Self only |
| Rating History | Full | Tenant/global scope | View-only assigned scope | Self only |
| Rankings | Full | Tenant/global scope | View-only assigned scope | Read-only public scope |
| Payments | Full | Own tenant | Assigned event scope | Self only |

## CRUD Permissions

| Action | Platform Admin | Court Owner | Staff | Player |
|---|---:|---:|---:|---:|
| Create | Full | Tenant scope | Operational scope | Self-scoped only |
| Read | Full | Tenant scope | Assigned scope | Self/scoped public |
| Update | Full | Tenant scope | Assigned operational scope | Self only |
| Delete | Controlled/soft delete | Tenant scope | Rarely allowed | Self cancellation only |

## Event Permissions

| Action | Platform Admin | Court Owner | Staff | Player |
|---|---:|---:|---:|---:|
| Create event | Full | Yes | No | No |
| Publish/unpublish | Full | Yes | No | No |
| Manage capacity | Full | Yes | Yes if authorized | No |
| Manage waitlist | Full | Yes | Yes if authorized | No |
| Check in players | Full | Yes | Yes | No |
| Mark no-show | Full | Yes | Yes if authorized | No |
| Close event | Full | Yes | Yes if authorized | No |

## Match Permissions

| Action | Platform Admin | Court Owner | Staff | Player |
|---|---:|---:|---:|---:|
| Generate matches | Full | Yes | Yes if authorized | No |
| View match details | Full | Tenant/global | Assigned scope | Self only |
| Submit score | Full | Yes | Yes | No |
| Verify score | Full | Yes | Yes if authorized | No |
| Cancel match | Full | Yes | Yes if authorized | No |
| Reopen match | Full | Controlled | Controlled | No |

## Rating Permissions

| Action | Platform Admin | Court Owner | Staff | Player |
|---|---:|---:|---:|---:|
| View ratings | Full | Tenant scope | Assigned scope | Self only |
| View rating history | Full | Tenant scope | Assigned scope | Self only |
| Recalculate ratings | Full | Controlled | No | No |
| Manually edit ratings | Controlled admin-only | No | No | No |

## Ranking Permissions

| Action | Platform Admin | Court Owner | Staff | Player |
|---|---:|---:|---:|---:|
| View rankings | Full | Tenant scope | Assigned scope | Public/self scope |
| View ranking history | Full | Tenant scope | Assigned scope | Self only |
| Recalculate rankings | Full | Controlled | No | No |
| Manually edit rankings | Controlled admin-only | No | No | No |

## Payment Permissions

| Action | Platform Admin | Court Owner | Staff | Player |
|---|---:|---:|---:|---:|
| Create payment intent | Full | Yes | No | Self only |
| Pay online | Full | Yes | No | Self only |
| Mark cash pending | Full | Yes | Yes | No |
| Confirm cash received | Full | Yes | Yes if authorized | No |
| Refund payment | Full | Yes | No | Self service only if supported |
| Void payment | Full | Yes | No | No |

## Ownership Rules

- platform admins own no tenant data by default, but may access all data through administrative scope
- court owners own tenants and tenant-managed resources
- staff own no business resources, only operational authority
- players own their own participation and profile data

## Court Isolation Rules

- all tenant-owned resources must include `tenant_id`
- all court-owned resources must include `court_id`
- staff and players must never access another tenant's private data
- cross-tenant access is only permitted to platform admins
