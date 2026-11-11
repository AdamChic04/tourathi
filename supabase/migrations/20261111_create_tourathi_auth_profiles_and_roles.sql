-- TouRathi: profiles and protected account roles
-- Already applied to Supabase project nxzqoncpesywoahscpwq.
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '' check (char_length(full_name) <= 120),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.account_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'tourist'
    check (role in ('tourist', 'organizer', 'seller', 'admin')),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.account_roles enable row level security;

create policy "User can read their own profile"
on public.profiles for select to authenticated
using (id = (select auth.uid()));

create policy "User can edit their own profile"
on public.profiles for update to authenticated
using (id = (select auth.uid()))
with check (id = (select auth.uid()));

create policy "User can read their own role"
on public.account_roles for select to authenticated
using (user_id = (select auth.uid()));

grant select, update on public.profiles to authenticated;
grant select on public.account_roles to authenticated;

create or replace function public.tourathi_create_user_profile()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name)
    values (new.id, left(coalesce(new.raw_user_meta_data ->> 'full_name', ''), 120));
  insert into public.account_roles (user_id, role)
    values (new.id, 'tourist');
  return new;
end;
$$;

create trigger on_tourathi_auth_user_created
after insert on auth.users
for each row execute function public.tourathi_create_user_profile();

create or replace function public.tourathi_touch_profile()
returns trigger language plpgsql set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;
create trigger on_tourathi_profile_updated
before update on public.profiles
for each row execute function public.tourathi_touch_profile();
