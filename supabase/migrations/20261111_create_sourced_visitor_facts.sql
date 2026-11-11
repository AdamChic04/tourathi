-- TouRathi source-attributed visitor research for all 61 destinations.
-- Each field is optional and must have its own provenance; NULL = not yet verified.
-- Do not treat a source check as real-time admission or opening guarantees.
create table public.place_visit_facts (
  place_id text primary key references public.places(id) on delete cascade,
  gps_lat double precision,
  gps_lon double precision,
  gps_precision text check (gps_precision in ('site_point','area_reference')),
  gps_source_url text,
  gps_source_name text,
  gps_checked_on date,
  hours_text_en text,
  hours_text_ar text,
  hours_source_url text,
  hours_source_name text,
  hours_checked_on date,
  admission_kind text check (admission_kind in ('site_entry','museum_entry','reserve_entry','guided_experience','vehicle_entry')),
  admission_name_en text,
  admission_name_ar text,
  admission_jordanian numeric(10,2),
  admission_resident numeric(10,2),
  admission_international numeric(10,2),
  admission_day_visitor numeric(10,2),
  admission_unit_en text,
  admission_unit_ar text,
  admission_conditions_en text,
  admission_conditions_ar text,
  admission_source_url text,
  admission_source_name text,
  admission_checked_on date,
  review_notes text,
  updated_at timestamptz not null default now(),
  constraint all_or_no_coordinates check ((gps_lat is null) = (gps_lon is null)),
  constraint jordan_latitude_range check (gps_lat is null or (gps_lat between 29 and 34)),
  constraint jordan_longitude_range check (gps_lon is null or (gps_lon between 34 and 40)),
  constraint coordinates_have_source check (gps_lat is null or (gps_source_url is not null and gps_checked_on is not null)),
  constraint hours_have_source check (hours_text_en is null or (hours_source_url is not null and hours_checked_on is not null)),
  constraint fees_have_source check (admission_kind is null or (admission_source_url is not null and admission_checked_on is not null)),
  constraint positive_admission check (
    (admission_jordanian is null or admission_jordanian >= 0) and
    (admission_resident is null or admission_resident >= 0) and
    (admission_international is null or admission_international >= 0) and
    (admission_day_visitor is null or admission_day_visitor >= 0)
  )
);
alter table public.place_visit_facts enable row level security;
revoke all on public.place_visit_facts from anon, authenticated;
grant select on public.place_visit_facts to authenticated;
create policy "Authenticated users read researched visitor facts"
on public.place_visit_facts for select to authenticated
using (exists (select 1 from public.places p
  where p.id = place_id and p.is_published = true));
insert into public.place_visit_facts(place_id)
select id from public.places
on conflict (place_id) do nothing;
