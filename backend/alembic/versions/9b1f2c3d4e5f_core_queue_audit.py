"""core_queue_audit

Revision ID: 9b1f2c3d4e5f
Revises: 7c0c59315145
Create Date: 2026-06-21 00:00:00.000000
"""
from typing import Sequence, Union

from alembic import op


revision: str = "9b1f2c3d4e5f"
down_revision: Union[str, Sequence[str], None] = "7c0c59315145"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("create extension if not exists pgcrypto")
    op.execute(
        """
        do $$
        begin
          if exists (select 1 from information_schema.columns where table_name = 'courts' and column_name = 'tenant_id') then
            alter table public.courts drop column tenant_id cascade;
          end if;
          if not exists (select 1 from information_schema.columns where table_name = 'courts' and column_name = 'owner_user_id') then
            alter table public.courts add column owner_user_id uuid references public.users(id) on delete restrict;
          end if;
          if not exists (select 1 from information_schema.columns where table_name = 'courts' and column_name = 'address') then
            alter table public.courts add column address text;
          end if;
          if not exists (select 1 from information_schema.columns where table_name = 'courts' and column_name = 'latitude') then
            alter table public.courts add column latitude numeric(10, 8);
          end if;
          if not exists (select 1 from information_schema.columns where table_name = 'courts' and column_name = 'longitude') then
            alter table public.courts add column longitude numeric(11, 8);
          end if;
          if not exists (select 1 from information_schema.columns where table_name = 'courts' and column_name = 'contact_info') then
            alter table public.courts add column contact_info text;
          end if;
        end $$;
        """
    )
    op.execute(
        """
        do $$
        declare
          v_table_name text;
        begin
          foreach v_table_name in array array[
            'court_memberships',
            'court_staff',
            'events',
            'event_registrations',
            'invitations',
            'matches',
            'match_participants',
            'player_ratings',
            'rankings',
            'rating_history',
            'score_submissions'
          ]
          loop
            if exists (
              select 1 from information_schema.columns
              where table_schema = 'public' and table_name = v_table_name and column_name = 'tenant_id'
            ) then
              execute format('alter table public.%I drop column tenant_id cascade', v_table_name);
            end if;
          end loop;
          drop table if exists public.tenants cascade;
        end $$;
        """
    )
    op.execute(
        """
        create table if not exists public.audit_logs (
          id uuid primary key default gen_random_uuid(),
          actor_user_id uuid references public.users(id) on delete set null,
          court_id uuid references public.courts(id) on delete set null,
          event_id uuid references public.events(id) on delete set null,
          match_id uuid references public.matches(id) on delete set null,
          action varchar not null,
          entity_type varchar not null,
          entity_id uuid,
          details_json jsonb,
          created_at timestamptz not null default now()
        )
        """
    )
    op.execute("create index if not exists ix_audit_logs_actor_user_id on public.audit_logs(actor_user_id)")
    op.execute("create index if not exists ix_audit_logs_court_id on public.audit_logs(court_id)")
    op.execute("create index if not exists ix_audit_logs_event_id on public.audit_logs(event_id)")
    op.execute("create index if not exists ix_audit_logs_match_id on public.audit_logs(match_id)")
    op.execute("create index if not exists ix_audit_logs_action on public.audit_logs(action)")
    op.execute(
        """
        create table if not exists public.event_queue_entries (
          id uuid primary key default gen_random_uuid(),
          court_id uuid not null references public.courts(id) on delete restrict,
          event_id uuid not null references public.events(id) on delete restrict,
          registration_id uuid not null references public.event_registrations(id) on delete restrict,
          user_id uuid not null references public.users(id) on delete restrict,
          assigned_match_id uuid references public.matches(id) on delete set null,
          status varchar not null default 'queued',
          queue_position integer,
          checked_in_at timestamptz not null default now(),
          assigned_at timestamptz,
          left_at timestamptz,
          returned_at timestamptz,
          created_at timestamptz not null default now(),
          updated_at timestamptz not null default now(),
          deleted_at timestamptz,
          created_by_user_id uuid references public.users(id) on delete set null,
          updated_by_user_id uuid references public.users(id) on delete set null,
          constraint uq_event_queue_entries_event_user unique(event_id, user_id)
        )
        """
    )
    op.execute("create index if not exists ix_event_queue_entries_court_id on public.event_queue_entries(court_id)")
    op.execute("create index if not exists ix_event_queue_entries_event_id on public.event_queue_entries(event_id)")
    op.execute("create index if not exists ix_event_queue_entries_registration_id on public.event_queue_entries(registration_id)")
    op.execute("create index if not exists ix_event_queue_entries_user_id on public.event_queue_entries(user_id)")
    op.execute("create index if not exists ix_event_queue_entries_assigned_match_id on public.event_queue_entries(assigned_match_id)")
    op.execute("create index if not exists ix_event_queue_entries_status on public.event_queue_entries(status)")


def downgrade() -> None:
    op.execute("drop table if exists public.event_queue_entries")
    op.execute("drop table if exists public.audit_logs")
