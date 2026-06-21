create extension if not exists pgcrypto;

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
);

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
);

create or replace function public.current_profile_id()
returns uuid
language sql
stable
as $$
  select id from public.users where supabase_user_id = auth.uid() limit 1
$$;

create or replace function public.is_platform_admin()
returns boolean
language sql
stable
as $$
  select exists (
    select 1 from public.users
    where supabase_user_id = auth.uid()
      and platform_role in ('platform_admin', 'super_admin')
      and status = 'active'
  )
$$;

create or replace function public.can_operate_court(target_court_id uuid)
returns boolean
language sql
stable
as $$
  select public.is_platform_admin()
    or exists (
      select 1 from public.courts c
      join public.users u on u.id = c.owner_user_id
      where c.id = target_court_id and u.supabase_user_id = auth.uid()
    )
    or exists (
      select 1 from public.court_staff s
      join public.users u on u.id = s.user_id
      where s.court_id = target_court_id and u.supabase_user_id = auth.uid() and s.status = 'active'
    )
$$;

create or replace function public.can_access_court(target_court_id uuid)
returns boolean
language sql
stable
as $$
  select public.can_operate_court(target_court_id)
    or exists (
      select 1 from public.court_memberships m
      join public.users u on u.id = m.user_id
      where m.court_id = target_court_id and u.supabase_user_id = auth.uid() and m.status = 'active'
    )
$$;

alter table public.users enable row level security;
alter table public.courts enable row level security;
alter table public.court_memberships enable row level security;
alter table public.court_staff enable row level security;
alter table public.events enable row level security;
alter table public.event_registrations enable row level security;
alter table public.event_queue_entries enable row level security;
alter table public.matches enable row level security;
alter table public.match_participants enable row level security;
alter table public.score_submissions enable row level security;
alter table public.player_ratings enable row level security;
alter table public.rankings enable row level security;
alter table public.audit_logs enable row level security;

do $$
begin
  if to_regclass('public.event_participants') is not null then
    alter table public.event_participants enable row level security;
  end if;
  if to_regclass('public.invitations') is not null then
    alter table public.invitations enable row level security;
  end if;
  if to_regclass('public.rating_history') is not null then
    alter table public.rating_history enable row level security;
  end if;
end $$;

drop policy if exists users_self_or_admin_select on public.users;
create policy users_self_or_admin_select on public.users
for select using (supabase_user_id = auth.uid() or public.is_platform_admin());

drop policy if exists users_self_update on public.users;
create policy users_self_update on public.users
for update using (supabase_user_id = auth.uid() or public.is_platform_admin())
with check (supabase_user_id = auth.uid() or public.is_platform_admin());

drop policy if exists courts_public_select on public.courts;
create policy courts_public_select on public.courts
for select using (status = 'active' or public.can_operate_court(id));

drop policy if exists courts_operator_write on public.courts;
create policy courts_operator_write on public.courts
for all using (public.can_operate_court(id))
with check (public.can_operate_court(id));

drop policy if exists court_memberships_scoped on public.court_memberships;
create policy court_memberships_scoped on public.court_memberships
for all using (user_id = public.current_profile_id() or public.can_operate_court(court_id))
with check (user_id = public.current_profile_id() or public.can_operate_court(court_id));

drop policy if exists court_staff_operator on public.court_staff;
create policy court_staff_operator on public.court_staff
for all using (user_id = public.current_profile_id() or public.can_operate_court(court_id))
with check (public.can_operate_court(court_id));

drop policy if exists events_public_or_scoped on public.events;
create policy events_public_or_scoped on public.events
for select using (visibility = 'public' or public.can_access_court(court_id));

drop policy if exists events_operator_write on public.events;
create policy events_operator_write on public.events
for all using (public.can_operate_court(court_id))
with check (public.can_operate_court(court_id));

drop policy if exists registrations_self_or_operator on public.event_registrations;
create policy registrations_self_or_operator on public.event_registrations
for all using (user_id = public.current_profile_id() or public.can_operate_court(court_id))
with check (user_id = public.current_profile_id() or public.can_operate_court(court_id));

drop policy if exists queue_self_or_operator on public.event_queue_entries;
create policy queue_self_or_operator on public.event_queue_entries
for all using (user_id = public.current_profile_id() or public.can_operate_court(court_id))
with check (user_id = public.current_profile_id() or public.can_operate_court(court_id));

drop policy if exists matches_participant_or_operator on public.matches;
create policy matches_participant_or_operator on public.matches
for select using (
  public.can_operate_court(court_id)
  or exists (
    select 1 from public.match_participants p
    where p.match_id = id and p.user_id = public.current_profile_id()
  )
);

drop policy if exists matches_operator_write on public.matches;
create policy matches_operator_write on public.matches
for all using (public.can_operate_court(court_id))
with check (public.can_operate_court(court_id));

drop policy if exists match_participants_visible on public.match_participants;
create policy match_participants_visible on public.match_participants
for select using (
  user_id = public.current_profile_id()
  or exists (
    select 1 from public.matches m
    where m.id = match_id and public.can_operate_court(m.court_id)
  )
);

drop policy if exists score_submissions_scoped on public.score_submissions;
create policy score_submissions_scoped on public.score_submissions
for all using (
  submitted_by_user_id = public.current_profile_id()
  or public.can_operate_court(court_id)
)
with check (
  submitted_by_user_id = public.current_profile_id()
  or public.can_operate_court(court_id)
);

drop policy if exists ratings_scoped_select on public.player_ratings;
create policy ratings_scoped_select on public.player_ratings
for select using (
  user_id = public.current_profile_id()
  or court_id is null
  or public.can_access_court(court_id)
);

drop policy if exists rankings_public_select on public.rankings;
create policy rankings_public_select on public.rankings
for select using (true);

do $$
begin
  if to_regclass('public.event_participants') is not null then
    execute 'drop policy if exists event_participants_self_or_operator on public.event_participants';
    execute 'create policy event_participants_self_or_operator on public.event_participants
      for all using (user_id = public.current_profile_id() or public.can_operate_court(court_id))
      with check (user_id = public.current_profile_id() or public.can_operate_court(court_id))';
  end if;

  if to_regclass('public.invitations') is not null then
    execute 'drop policy if exists invitations_self_or_operator on public.invitations';
    execute 'create policy invitations_self_or_operator on public.invitations
      for all using (
        public.is_platform_admin()
        or invited_by_user_id = public.current_profile_id()
        or invitee_user_id = public.current_profile_id()
        or public.can_operate_court(court_id)
      )
      with check (
        public.is_platform_admin()
        or invited_by_user_id = public.current_profile_id()
        or public.can_operate_court(court_id)
      )';
  end if;

  if to_regclass('public.rating_history') is not null then
    execute 'drop policy if exists rating_history_scoped_select on public.rating_history';
    execute 'create policy rating_history_scoped_select on public.rating_history
      for select using (
        user_id = public.current_profile_id()
        or court_id is null
        or public.can_access_court(court_id)
      )';
  end if;
end $$;

drop policy if exists audit_operator_select on public.audit_logs;
create policy audit_operator_select on public.audit_logs
for select using (public.is_platform_admin() or public.can_operate_court(court_id));
