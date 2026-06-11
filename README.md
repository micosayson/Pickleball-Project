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

The backend now includes:

- domain models for users, courts, events, matches, ratings, rankings, and related history tables
- Alembic migrations for the initial schema
- a demo seed script for test data
- a local backend virtual environment at `backend/.venv`

### Frontend

The Flutter app is still a future step. No screens have been generated yet.

## Today’s Progress

Completed in this session:

1. Generated and corrected the backend SQLAlchemy model layer
2. Fixed Alembic template generation so autogenerate emits real DDL
3. Ran Alembic migrations successfully against Supabase PostgreSQL
4. Created demo seed data for:
   - Platform Admin: Mico
   - Court Owner tenant: Smash Zone
   - Test Court
   - Test Staff: Staff 1
   - Test Players: Player A, Player B, Player C, Player D
   - Test Event: Thursday Competitive Play
   - seed match, score submission, ratings, rating history, and rankings
5. Created a backend virtual environment and installed project dependencies
6. Fixed the generator typing issue in `get_db()` for Pylance
7. Added local VS Code settings for backend interpreter resolution

## Backend Status

The backend skeleton is now in place under `backend/`.

Working pieces:

- SQLAlchemy models
- Alembic migration flow
- Supabase connection through the backend configuration
- demo seed data
- project-local Python virtual environment

Still to build:

- FastAPI route implementations
- auth flows
- tenant resolution middleware
- permission guards
- event engine business logic
- rating and ranking workflows
- Flutter UI

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
- [Permission Matrix](docs/permission_matrix.md)

## Next Steps

1. Implement the FastAPI skeleton endpoints
2. Add auth and tenant-scoped request handling
3. Build event, match, rating, and ranking services
4. Start Flutter frontend scaffolding
