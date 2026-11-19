create extension if not exists pgcrypto;

create table if not exists public.travel_journal_entries (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 80),
  body text not null default '' check (char_length(body) <= 1000),
  visibility text not null default 'private' check (visibility in ('private','shared')),
  place_id text,
  place_name text,
  trip_id text,
  trip_name text,
  photo_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists travel_journal_owner_created_idx
  on public.travel_journal_entries(user_id, created_at desc);
create index if not exists travel_journal_shared_created_idx
  on public.travel_journal_entries(created_at desc) where visibility = 'shared';

alter table public.travel_journal_entries enable row level security;
create policy "Owners read their journal" on public.travel_journal_entries
  for select to authenticated using (auth.uid() = user_id);
create policy "Community reads shared journal entries" on public.travel_journal_entries
  for select to authenticated using (visibility = 'shared');
create policy "Owners create their journal entries" on public.travel_journal_entries
  for insert to authenticated with check (auth.uid() = user_id);
create policy "Owners update their journal entries" on public.travel_journal_entries
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Owners delete their journal entries" on public.travel_journal_entries
  for delete to authenticated using (auth.uid() = user_id);

create table if not exists public.travel_journal_likes (
  entry_id text not null references public.travel_journal_entries(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(entry_id, user_id)
);
alter table public.travel_journal_likes enable row level security;
create policy "Users read likes on visible entries" on public.travel_journal_likes for select to authenticated
  using (user_id = auth.uid() or exists(select 1 from public.travel_journal_entries e where e.id = entry_id and e.visibility = 'shared'));
create policy "Users like visible entries" on public.travel_journal_likes for insert to authenticated
  with check (user_id = auth.uid() and exists(select 1 from public.travel_journal_entries e where e.id = entry_id and (e.visibility = 'shared' or e.user_id = auth.uid())));
create policy "Users remove their likes" on public.travel_journal_likes for delete to authenticated using (user_id = auth.uid());

create table if not exists public.travel_journal_comments (
  id uuid primary key default gen_random_uuid(),
  entry_id text not null references public.travel_journal_entries(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  body text not null check(char_length(body) between 1 and 280),
  created_at timestamptz not null default now()
);
create index if not exists travel_journal_comments_entry_created_idx on public.travel_journal_comments(entry_id, created_at);
alter table public.travel_journal_comments enable row level security;
create policy "Users read comments on visible entries" on public.travel_journal_comments for select to authenticated
  using (user_id = auth.uid() or exists(select 1 from public.travel_journal_entries e where e.id = entry_id and e.visibility = 'shared'));
create policy "Users comment on visible entries" on public.travel_journal_comments for insert to authenticated
  with check (user_id = auth.uid() and exists(select 1 from public.travel_journal_entries e where e.id = entry_id and (e.visibility = 'shared' or e.user_id = auth.uid())));

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('journal-media','journal-media',false,10485760,array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;
create policy "Owners upload journal photos" on storage.objects for insert to authenticated
  with check (bucket_id = 'journal-media' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "Owners read journal photos" on storage.objects for select to authenticated
  using (bucket_id = 'journal-media' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "Community reads photos for shared entries" on storage.objects for select to authenticated
  using (bucket_id = 'journal-media' and exists (
    select 1 from public.travel_journal_entries e
    where e.photo_path = name and e.visibility = 'shared'
  ));
create policy "Owners update journal photos" on storage.objects for update to authenticated
  using (bucket_id = 'journal-media' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'journal-media' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "Owners delete journal photos" on storage.objects for delete to authenticated
  using (bucket_id = 'journal-media' and (storage.foldername(name))[1] = auth.uid()::text);
