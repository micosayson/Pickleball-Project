# Project Roadmap

This roadmap separates what is already a concrete foundation from what is still in progress.

## What Is Already Solid

- Flutter app shell is working
- Supabase Auth sign-in and sign-up are wired in Flutter
- FastAPI app boots and serves routes
- backend profile sync works through `/api/v1/users/sync`
- demo seed data exists for local testing
- Supabase auth trigger auto-creates a `public.users` profile row

## Backend In Progress

These pieces still need to be finished or hardened before the backend is considered complete:

- tenant resolution dependency
- authenticated principal dependency
- real permission guards
- tenant-scoped query enforcement in services/repositories
- remaining CRUD endpoints for courts, events, matches, ratings, rankings, and invitations
- audit logging for important actions
- production-grade error handling and validation

## Supabase RLS In Progress

These are the current RLS-related gaps:

- RLS is enabled on the main tables
- policy definitions are still mostly placeholders or not yet created
- policies for select/insert/update/delete still need to be written per table
- ownership rules need to be mapped to the new court-centric model
- auth-triggered profile creation is done, but data access rules are not finished
- the app still needs clear policy coverage for player, staff, court owner, and super admin access

## Recommended Order

1. Finish backend auth and tenant context
2. Write the actual RLS policies
3. Verify backend queries respect tenant scope
4. Add the remaining CRUD endpoints
5. Expand the frontend UI and connect it to the stable backend contracts

## When It Is Safe To Focus On UI

You can move harder into frontend work when:

- login and register work without repeated auth errors
- `/api/v1/users/sync` returns 200 reliably
- tenant context is resolved for authenticated requests
- the main RLS policies are in place
- the backend returns stable JSON shapes for the UI to consume

## Practical Summary

Right now, the project has a usable foundation, but backend authorization and Supabase RLS are not fully finished yet.
That means you can continue frontend work now, but the backend and database rules still need follow-up before the app is production safe.
