"""notifications_table

Revision ID: c7b1f4a8a9e2
Revises: 9b1f2c3d4e5f
Create Date: 2026-06-30 00:00:00.000000
"""
from typing import Sequence, Union

from alembic import op


revision: str = "c7b1f4a8a9e2"
down_revision: Union[str, Sequence[str], None] = "9b1f2c3d4e5f"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("create extension if not exists pgcrypto")
    op.execute(
        """
        create table if not exists public.notifications (
          id uuid primary key default gen_random_uuid(),
          recipient_user_id uuid not null references public.users(id) on delete cascade,
          actor_user_id uuid references public.users(id) on delete set null,
          notification_type varchar not null,
          category varchar not null default 'general',
          title varchar not null,
          body text not null,
          action_url varchar,
          related_entity_type varchar,
          related_entity_id uuid,
          metadata_json jsonb,
          read_at timestamptz,
          created_at timestamptz not null default now(),
          updated_at timestamptz not null default now(),
          deleted_at timestamptz,
          created_by_user_id uuid references public.users(id) on delete set null,
          updated_by_user_id uuid references public.users(id) on delete set null
        )
        """
    )
    op.execute("create index if not exists ix_notifications_recipient_user_id on public.notifications(recipient_user_id)")
    op.execute("create index if not exists ix_notifications_actor_user_id on public.notifications(actor_user_id)")
    op.execute("create index if not exists ix_notifications_notification_type on public.notifications(notification_type)")
    op.execute("create index if not exists ix_notifications_category on public.notifications(category)")
    op.execute("create index if not exists ix_notifications_related_entity_type on public.notifications(related_entity_type)")
    op.execute("create index if not exists ix_notifications_related_entity_id on public.notifications(related_entity_id)")
    op.execute("create index if not exists ix_notifications_read_at on public.notifications(read_at)")
    op.execute(
        "create index if not exists ix_notifications_recipient_read_at on public.notifications(recipient_user_id, read_at)"
    )


def downgrade() -> None:
    op.execute("drop table if exists public.notifications")
