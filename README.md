# Pickleball Platform

Multi-tenant pickleball platform monorepo.

## Repository Layout

```text
Pickleball-Project/
  backend/
    app/
    alembic/
    scripts/
    .venv/
    pyproject.toml
  frontend/
  docs/
    handoff.md
    permission_matrix.md
  README.md
```

## Product Vision

The platform is player-first.

- Players discover nearby courts and events
- Players join open play and competitive play
- Players build ratings and rankings from real matches
- Players can participate across multiple courts and communities

## Tech Stack

- Frontend: Flutter web and mobile
- Backend: FastAPI
- ORM: SQLAlchemy 2.0
- Migrations: Alembic
- Database: Supabase PostgreSQL
- Auth: Supabase Auth
- Storage: Supabase Storage

## Architecture Principles

- Business logic belongs in FastAPI services
- Supabase is infrastructure only: auth, database hosting, and storage
- Tenant-owned records must remain tenant-scoped
- Competitive workflows must be auditable and deterministic
- Match outcomes drive ratings, and ratings drive rankings

## Current Project Structure

### Backend

The backend currently includes:

- domain models for users, courts, events, matches, ratings, rankings, and related history tables
- FastAPI routes for auth checks, user profile sync, and test endpoints
- Alembic migrations for the schema
- a demo seed script for test data
- a local backend virtual environment at `backend/.venv`

### Frontend

The Flutter app is active now, not a future step.

It currently includes:

- Supabase Auth login and sign-up flow
- an `AuthGate` that routes between auth and the signed-in view
- a signed-in home screen
- a small backend API tester for GET, POST, and PATCH calls

## Current Status

The codebase is mostly aligned with the intended architecture.

Working pieces:

- SQLAlchemy models
- Alembic migration flow
- Supabase connection through the backend configuration
- Supabase Auth in Flutter
- FastAPI request handling and JWT validation
- demo seed data
- project-local Python virtual environment

Still in progress:

- tenant resolution middleware
- permission guards
- event engine business logic
- rating and ranking workflows
- full production UI
- more backend CRUD endpoints

## Environment Notes

- Keep secrets in `backend/.env`
- Do not commit Supabase passwords or service role keys
- Use the backend virtual environment for local development:

```powershell
backend\.venv\Scripts\python.exe
```

## Useful Commands

Run from `backend/`:

```powershell
python -m alembic upgrade head
python scripts/seed_demo.py
```

If you want to verify the seed data in Supabase, check the `public.events` table for:

- `Thursday Competitive Play`

## Docs

- [Handoff](docs/handoff.md)
- [Roadmap](docs/roadmap.md)
- [Permission Matrix](docs/permission_matrix.md)

## Next Steps

1. Add tenant-aware request handling
2. Build the remaining event, match, rating, and ranking services
3. Expand the Flutter UI beyond the current auth and home flow
4. Add more CRUD endpoints and integration tests
