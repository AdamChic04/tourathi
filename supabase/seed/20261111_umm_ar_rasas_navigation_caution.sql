-- Two official archaeological references identify different points around
-- Umm ar-Rasas. Treat the existing DoA coordinate as a heritage-area
-- reference only, NOT a reliable routing point or visitor entrance.
-- Preserve the source URL and original numeric values for later review.
update public.place_visit_facts
set gps_precision = 'area_reference',
    review_notes = concat_ws(' ', review_notes,
      'Department of Antiquities and UNESCO list differing location references for Umm ar-Rasas; check entrance position before using routing. UNESCO: https://whc.unesco.org/en/list/1093/maps'),
    updated_at = now()
where place_id = 'madaba-umm-ar-rasas'
  and gps_source_url like 'https://doa.gov.jo/%';
