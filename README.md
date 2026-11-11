# TouRathi — Flutter UI milestone

This repository contains **only the TouRathi screens developed so far**, not the unfinished screens supplied by the original demo project.

## Implemented

- Animated centered TouRathi splash / compass symbol, then automatic Home transition.
- Clean Home screen with four automatically sliding destination visuals, search shortcut, destination cards and favorites.
- Redesigned Explore Jordan screen with search, categories, sorting, favorites, and an illustrative (non-live) map overview.
- Simple destination-details screen and working Home / Explore navigation.
- English and Arabic labels, light / dark theme foundations.

The catalog contains 61 destinations in 12 governorates, with 61 bundled licensed images. Image sources and reuse terms are documented in [image attributions](assets/images/places/ATTRIBUTION.md); some are regional representative images, not exact-site photographs. Place descriptions are prototype text, and ratings are unavailable. Favorites currently last only while the app is running.

## Place catalog and Supabase

The project's 61 owner-supplied destinations are stored in the `public.places` table, with protected read access to authenticated users. Home, Explore and the existing itinerary planner read the same in-memory catalog after it refreshes from Supabase; the matching bundled data and images work as a fallback when offline. Supabase migrations and an idempotent seed SQL file are in `supabase/`.

Real-time map navigation, verified opening hours, prices, coordinates, and public visitor ratings are not supplied by this dataset.

## Destination details (new)

Every one of the 61 destinations now has an English/Arabic editorial overview, a full-bleed photo hero with pinch-to-zoom viewer, visible photo creator/license/source attribution, same-governorate suggestions, and a Google Maps search/directions shortcut.

Hours appear **only** where a source record exists (currently Petra). Published price references show their source and check date; they are not live ticket prices, and some refer to guided activities rather than site entry. No price is invented for unverified locations.

The current photo set has **one image per destination**, not a multi-image gallery. Some photos are representative of the wider region, which the UI labels explicitly. Directions launch Google Maps using a place-name search: the catalog does not have validated coordinates, so users must verify the map result.

The 61 editorial descriptions are marked unverified in Supabase; official visitor details must be confirmed before travel.

## Research-backed visitor facts

Each of the 61 destinations has a record in `public.place_visit_facts`, with nullable, independently source-linked coordinates, published hours, admission fee categories and check dates.

As of 2026-11-11, **10** have published source coordinates (5 site points, 5 UNESCO heritage property reference points), **15** have source-based schedules, and **28** have admission/entrance fee references. All other fields are **unknown, not free / not open**. Some published rates are from older operator sheets or grouped government schedules, and conditions must be checked before traveling.

The app loads researched facts from Supabase after sign-in. The destination page prefers researched details, showing direct source links and check dates. Only destinations with site-point coordinates use coordinates for Google Maps; UNESCO area reference points and all other places use a name search.

See [visitor research notes](RESEARCH_VISIT_FACTS.md) and the SQL migration and repeatable seed in `supabase/`.

## Not implemented yet

Organizer/seller/admin portals, AI image/video generator, AR, full maps/navigation, marketplace, group chat, and bookings. Authentication and the secure user profile/role tables are now connected to Supabase. Visible shortcut buttons for upcoming features lead to an explicit **Coming soon** screen.

## Run

Install the Flutter SDK, then from the repository root:

```bash
flutter pub get
flutter run -d chrome
```

The animated splash opens Login for signed-out visitors and Home for signed-in users. See [Authentication setup](README_AUTH.md) for email link configuration.

## Project structure

- `lib/features/splash/`: opening animation
- `lib/features/home/`: Home
- `lib/features/explore/`: Explore Jordan
- `lib/features/place_details/`: destination preview
- `lib/features/coming_soon/`: honest placeholders
- `lib/core/`: routing, theme and session state
- `lib/data/`: small sample destination model and records
- `assets/images/home/`: four locally bundled illustrative destination visuals

**Milestone:** Flutter UI plus Supabase email/password authentication. There is not yet a role-specific admin or organizer portal. Flutter build and device testing should be performed on the developer's computer.
