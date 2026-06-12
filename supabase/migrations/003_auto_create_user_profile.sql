-- Auto-create a public.users profile row whenever Supabase Auth creates a user.
-- This runs at signup time, so it works even when email confirmation is enabled.

create extension if not exists pgcrypto;

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (
    id,
    supabase_user_id,
    email,
    full_name,
    avatar_url,
    platform_role,
    status
  )
  values (
    gen_random_uuid(),
    new.id,
    coalesce(new.email, ''),
    nullif(new.raw_user_meta_data ->> 'full_name', ''),
    nullif(new.raw_user_meta_data ->> 'avatar_url', ''),
    coalesce(nullif(new.raw_user_meta_data ->> 'platform_role', ''), 'player'),
    'active'
  )
  on conflict (supabase_user_id) do update
    set email = excluded.email,
        full_name = coalesce(excluded.full_name, public.users.full_name),
        avatar_url = coalesce(excluded.avatar_url, public.users.avatar_url),
        platform_role = coalesce(excluded.platform_role, public.users.platform_role);

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_auth_user();
