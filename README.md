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
