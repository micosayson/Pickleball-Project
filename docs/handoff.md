# Handoff Notes

This document is intended for any developer picking up the pickleball platform workstream.

## Session Update

This first implementation session completed the backend foundation and seeded the database with demo records.

What was finished today:

- corrected the backend repository structure into a monorepo layout
- generated the backend SQLAlchemy model layer
- fixed Alembic template generation so autogenerate produces real migration DDL
- ran migrations successfully into Supabase PostgreSQL
- seeded demo data for users, tenant, courts, memberships, staff, event, match, score submission, ratings, rating history, and rankings
- created a backend-local virtual environment for clean dependency resolution
- fixed the `get_db()` generator typing issue for Pylance
- added local VS Code settings so the backend interpreter resolves correctly

Verified seeded demo entities:

- Platform Admin: Mico
- Court Owner tenant: Smash Zone
- Test Court
- Test Staff: Staff 1
- Test Players: Player A, Player B, Player C, Player D
- Test Event: Thursday Competitive Play

## Project Goal

Build a multi-tenant pickleball platform where players can:

- discover courts nearby
- discover events nearby
- join open play events
- join competitive play events
- build ratings
- build rankings
- participate in multiple court communities

The product should feel player-first, with courts and clubs acting as community hosts and operational owners.

## Business Context

This platform is inspired by Sports360, Reclub, DUPR, and Playtomic.

Important product rule:

- players are not permanently tied to a single court
- players may belong to multiple communities
- ratings and rankings should follow the player across compatible competitive contexts

## Technical Direction

### Frontend
- Flutter web and mobile

### Backend
- FastAPI
- SQLAlchemy
- Alembic
- Pydantic v2

### Database
- Supabase PostgreSQL

### Supabase Usage
- authentication
- database hosting
- storage

Important:

- do not implement business logic in Supabase
- keep business rules in FastAPI services

## Roles

- Super Admin
- Court Owner
- Staff
- Player

## Core Workflows

### Discovery
- players find nearby courts and events
- players filter by distance, time, event type, and competitive level

### Open Play
- players join casual events
- staff manages check-in and rotation
- participation is the primary outcome

### Competitive Play
- event runs for several hours
- multiple matches happen within one event
- scores are submitted per match
- ratings update from completed matches
- rankings update from ratings

### Seed Data Workflow
- the backend includes a repeatable seed script for demo records
- seed data is intended for local testing and early integration verification only
- production seed values should be replaced before launch

### Tournament Play
- tournament structure may vary
- bracket or structured progression is expected
- competitive integrity and auditability are important

## Implementation Guidance

### Backend Architecture
Use a domain-oriented structure with clear separation between:

- API routes
- service layer
- repositories
- database models
- permissions
- tenant context

### Suggested Domain Areas
- auth
- tenants
- users
- courts
- invitations
- events
- matches
- scoring
- ratings
- rankings
- tournaments
- storage
- notifications

### Backend Repository Status
- `backend/` is the active FastAPI repository
- `frontend/` is reserved for the Flutter application
- `docs/` holds architecture and handoff documentation
- `backend/.venv` should be used as the local Python environment

## Multi-Tenant Rules

- every tenant-owned table should be tenant-scoped
- every repository query should respect tenant context
- staff and players must only see data inside their authorized tenant scope
- Super Admin can access the platform globally
- Supabase is used for infrastructure only and must not contain business logic

## Permission Model

### Super Admin
- manage all tenants
- inspect all platform data
- handle platform-level oversight

### Court Owner
- create and manage courts
- manage staff
- create and manage events
- view community statistics

### Staff
- support operations
- check in players
- manage live event flow
- submit or verify scores when authorized

### Player
- discover courts and events
- join events
- participate in matches
- view ratings and rankings

## Competitive Play Flow

1. Event is created
2. Players join
3. Matches are generated or assigned
4. Scores are submitted per match
5. Scores are verified and finalized
6. Ratings are recalculated
7. Rankings are updated

Important:

- match results must be auditable
- rating updates must be traceable to completed matches
- ranking updates must follow rating updates
- seed data includes one completed competitive match to validate this flow end-to-end

## Handoff Checklist

Before a developer starts implementation, confirm:

- tenant boundaries are defined
- role permissions are agreed
- event lifecycle states are finalized
- match scoring rules are documented
- rating model is selected
- ranking scopes are defined
- storage usage conventions are clear
- backend virtual environment is selected in VS Code
- Supabase connection settings are loaded from `backend/.env`
- demo seed data is present and can be verified from Supabase SQL Editor

## Suggested Order Of Work

1. Finalize domain model and workflows
2. Define permissions and tenant context
3. Scaffold FastAPI project structure
4. Implement auth and membership handling
5. Implement events, matches, and scoring
6. Implement ratings and rankings
7. Add audit logging and notifications
8. Connect Flutter frontend
9. Expand seed data and test fixtures as the API grows

## Open Questions

- Should rankings be global, tenant-scoped, event-scoped, or all three?
- Should competitive ratings use a single universal model or multiple rating types?
- Should tournaments reuse the same match workflow or have a separate bracket engine?
- Should event discovery be fully public or partially gated by login?

## Definition Of Done For Core Competitive Play

The core competitive flow is ready when:

- a player can discover and join a competitive event
- matches can be assigned and played
- scores can be submitted and verified
- ratings update from match results
- rankings update from ratings
- every action is tenant-safe and auditable

## Current Status

Backend infrastructure status:

- monorepo layout is established
- backend models and migrations are in place
- Supabase schema has been created
- sample data has been seeded successfully
- local Python environment is configured for backend development

Immediate next implementation targets:

1. `POST /auth/login`
2. `POST /courts`
3. `POST /events`
4. `POST /events/{id}/join`
5. `POST /matches`
6. `POST /scores`

## Notes For The Next Developer

- Keep player experience central
- Keep business logic in FastAPI
- Treat Supabase as infrastructure, not workflow logic
- Favor explicit state transitions over implicit behavior
- Build for multi-tenant safety from the start
- Keep the current seed data available as a regression baseline while implementing the first CRUD endpoints
