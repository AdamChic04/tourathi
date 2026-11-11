-- Five UNESCO World Heritage property reference coordinates.
-- These are declared property positions, not entrance gates or driving pins.
update public.place_visit_facts set
 gps_lat=30.33056, gps_lon=35.44333, gps_precision='area_reference',
 gps_source_url='https://whc.unesco.org/en/list/326/maps',
 gps_source_name='UNESCO World Heritage Centre (Petra property)',
 gps_checked_on='2026-11-11',
 updated_at=now()
where place_id='maan-petra'
  and gps_lat is null;

update public.place_visit_facts set
 gps_lat=31.8018056, gps_lon=36.5873056, gps_precision='area_reference',
 gps_source_url='https://whc.unesco.org/en/list/327/maps',
 gps_source_name='UNESCO World Heritage Centre (Quseir Amra property)',
 gps_checked_on='2026-11-11',
 updated_at=now()
where place_id='zarqa-qasr-amra'
  and gps_lat is null;

update public.place_visit_facts set
 gps_lat=29.6397222, gps_lon=35.4338889, gps_precision='area_reference',
 gps_source_url='https://whc.unesco.org/en/list/1377/maps',
 gps_source_name='UNESCO World Heritage Centre (Wadi Rum property)',
 gps_checked_on='2026-11-11',
 review_notes='UNESCO''s Wadi Rum nomination documents identify the protected area as within Aqaba Governorate. Dataset governorate is Ma''an; needs correction.',
 updated_at=now()
where place_id='maan-wadi-rum'
  and gps_lat is null;

update public.place_visit_facts set
 gps_lat=32.0426111, gps_lon=35.7283056, gps_precision='area_reference',
 gps_source_url='https://whc.unesco.org/en/list/689/maps',
 gps_source_name='UNESCO World Heritage Centre (As-Salt historic urban property)',
 gps_checked_on='2026-11-11',
 updated_at=now()
where place_id='balqa-as-salt'
  and gps_lat is null;

update public.place_visit_facts set
 gps_lat=32.3269444, gps_lon=36.37, gps_precision='area_reference',
 gps_source_url='https://whc.unesco.org/en/list/1721/maps',
 gps_source_name='UNESCO World Heritage Centre (Umm Al-Jimāl property)',
 gps_checked_on='2026-11-11',
 updated_at=now()
where place_id='mafraq-umm-al-jimal'
  and gps_lat is null;
