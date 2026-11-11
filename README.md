# TouRathi — Flutter UI milestone

This repository contains **only the TouRathi screens developed so far**, not the unfinished screens supplied by the original demo project.

## Implemented

- Animated centered TouRathi splash / compass symbol, then automatic Home transition.
- Clean Home screen with four automatically sliding destination visuals, search shortcut, destination cards and favorites.
- Redesigned Explore Jordan screen with search, categories, sorting, favorites, and an illustrative (non-live) map overview.
- Simple destination-details screen and working Home / Explore navigation.
- English and Arabic labels, light / dark theme foundations.

All four bundled destination images are **AI-generated illustrative demo images**, not actual photographs of the sites. Place ratings and descriptions are sample content. Favorites currently last only while the app is running.

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
