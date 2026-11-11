# TouRathi — Researched visit information

Research checked **2026-11-11** against the referenced official/government/operator publications. This is **not a real-time availability check**.

## Coverage (61 locations)

| Field | With supported data | Without supported data |
| --- | ---: | ---: |
| Sourced site coordinates or heritage-area references | 10 | 51 |
| Published schedule / office hours | 15 | 46 |
| Published admission/entry price reference | 28 | 33 |

Every location has a `place_visit_facts` row, even when fields are unavailable. Null values are intentional: we do not infer that a site is free, always open, accessible, or located at a guessed map pin. The 61 destination names, descriptions and photo source credits are separate from these operational facts.

## Sources and how they are used

- [Jordan Department of Antiquities eTicket fees](https://www.ticket.gov.jo/en/prices): published admission prices for named archaeological sites; rates differentiate Jordanian and non-Jordanian visitors.
- [Department of Antiquities opening-hours table](https://ticket.gov.jo/en/opening-hours): published winter/summer and Ramadan schedules for named archaeological sites. The page has overlapping seasonal descriptions ("winter Nov–Apr" vs "April and May") so the app labels the schedule and asks users to check.
- [Jordan Tourism Board admission and reserve fees](https://international.visitjordan.com/page/17/entrance-fees/): Petra, Mount Nebo, reserves and museum rates; grouped-site and tax conditions are kept visible. This table does not establish the fees of unrelated craft workshops.
- [Official Petra ticket rates](https://visitpetra.jo/en/Petrafees) and [official Petra opening hours](https://www.visitpetra.jo/en/Openinghours): one-day and special ticket classes, seasonal site/visitor center hours, and Little Petra **ticket office** hours. Ticket office schedules are not guaranteed full site access hours.
- [Jordan Museums — Jordan Museum](https://museums.visitjordan.com/en/Museum/5), [Abu Jaber museum](https://museums.visitjordan.com/en/museum/13), [Dar as-Saraya](https://museums.visitjordan.com/en/Museum/14), and [Arar's Cultural House](https://museums.visitjordan.com/en/Museum/35): venue-specific opening hours; any listed exceptions are retained.
- [Jordan Department of Antiquities archaeological site coordinates](https://doa.gov.jo/EN/ListDetails/Archeological_Sites/1157/2) and governorate listings for [Ajloun](https://doa.gov.jo/AR/ListDetails/%D9%85%D9%88%D8%A7%D9%82%D8%B9_%D8%A3%D8%AB%D8%B1%D9%8A%D8%A9/1145/7), [Tafilah](https://doa.gov.jo/AR/ListDetails/%D9%85%D9%88%D8%A7%D9%82%D8%B9_%D8%A3%D8%AB%D8%B1%D9%8A%D8%A9/1145/14), and [Umm ar-Rasas](https://doa.gov.jo/AR/ListDetails/%D9%85%D9%88%D8%A7%D9%82%D8%B9_%D8%A3%D8%AB%D8%B1%D9%8A%D8%A9/1145/8): five site references, **not verified entrance gate locations**.
- [UNESCO Petra](https://whc.unesco.org/en/list/326/maps), [Quseir Amra](https://whc.unesco.org/en/list/327/maps), [Wadi Rum](https://whc.unesco.org/en/list/1377/maps), [As-Salt](https://whc.unesco.org/en/list/689/maps) and [Umm Al-Jimāl](https://whc.unesco.org/en/list/1721/maps) World Heritage property coordinates: five extra **area reference points**. Because these are not entrance locations, TouRathi continues to open a place-name Maps search for them.
- [RSCN Azraq operator rates (2025)](https://www.rscn.org.jo/uploaded_files/reservation/AZRAQ%202025-1.pdf) and [RSCN Shaumari operator rates (2025)](https://rscn.org.jo/uploaded_files/reservation/Shaumari%202025-1.pdf): older operator sheets. Discrepancies against the JTB reserve table are flagged; confirm with RSCN before relying on them.

## Known review issues

- **Wadi Rum** appears under Ma’an in the supplied dataset, but UNESCO nomination material places the protected area in Aqaba Governorate. The original record is flagged for correction.
- **Dhiban** is classified under Karak in the supplied dataset, but the Department of Antiquities describes it within Madaba Governorate. Its original dataset record is preserved pending correction.
- **Umm ar-Rasas** appears under different administrative/grouping classifications across sources. Keep its published site coordinates without assuming the supplied governorate assignment is definitive.
- **Shaumari and Azraq reserve pricing** can differ by publication year and fee/tax treatment. Recheck directly with RSCN.
- **Desert castles** use a group-ticket reference; a listed fee does not establish whether the ticket grants access to multiple sites or confirms those sites' opening status.
- Many places are villages, trail areas, seasonal waterfalls, or bookable experiences rather than staffed attractions. Opening hours and fixed admission prices may not exist. **No free-entry claim is inferred**.

## App / database behavior

`public.place_visit_facts` has read-only access for authenticated travelers through RLS. No public writes. The Flutter details screen prefers this database research and shows sources/check dates. If the source data cannot load, the app falls back to its bundled destination descriptions and previously referenced price and Petra-hours catalog, not unsourced placeholder numbers.

The schema is in `supabase/migrations/20261111_create_sourced_visitor_facts.sql`; researched values in `supabase/seed/20261111_researched_visit_facts.sql`.

Before a public launch, complete field verification for unresolved locations; check opening hours before arrival, check operator fees, confirm coordinates are usable for navigation, and correct governorate mismatches.
