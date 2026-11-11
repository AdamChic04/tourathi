-- TouRathi's canonical, read-only tourist catalog.
create table public.places (
  id text primary key check (id ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  name_en text not null,
  name_ar text not null,
  governorate text not null,
  category text not null check (category in ('heritage','museums','food','hiking','religious','adventure')),
  discovery_context text not null default '',
  description_en text not null default '',
  description_ar text not null default '',
  image_asset text not null default '',
  sort_order integer not null default 0,
  is_verified boolean not null default false,
  is_published boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index places_category_idx on public.places (category);
create index places_governorate_idx on public.places (governorate);
create index places_published_order_idx on public.places (is_published, sort_order);
alter table public.places enable row level security;
revoke all on public.places from anon, authenticated;
grant select on public.places to authenticated;
create policy "Authenticated travelers can browse published places"
  on public.places for select to authenticated
  using (is_published = true);
