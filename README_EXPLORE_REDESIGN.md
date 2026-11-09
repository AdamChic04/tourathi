# TouRathi — Explore Jordan (redesigned)

This update keeps the existing Flutter app, centered animated opening splash,
Home photo slider, and bottom navigation. Explore is the second tab in MainShell.

## Included in Explore
- Clean search across English/Arabic titles, descriptions, and locations.
- Simple categories (All, Heritage, Nature, Adventure).
- A grid of destination illustrations bundled in assets/images/home/ (works offline).
- Favorites shared in memory between Home, Explore, and Place Details.
- Saved-only filter, Featured or Name A–Z sort, and reset-empty-results.
- An illustrative geographic overview with tappable place markers. It is a
  schematic, NOT a live map, navigation service or road map.
- Tap a place to open the existing Place Details screen. Popular place hero
  illustrations now load from bundled assets rather than unrelated image URLs.
- AI itinerary shortcut opens the existing AI Trip Planner screen.
- English/Arabic labels and light/dark color palette.

## Scope and current limits
- Only the four demo places in `MockData.popularPlaces` with local imagery are
  shown: Petra, Jerash, Wadi Rum, Dead Sea.
- Existing demo descriptions, prices, ratings, hours, and review counts are
  placeholders, not verified travel information.
- Bundled images are AI-created demonstration illustrations, not genuine
  photographs. Replace with properly licensed destination photos later.
- Favorites are kept in AppProvider for the current app session only; they are
  not yet synced or saved to Supabase.
- The map overview is not Mapbox. Connect Mapbox after API credentials and
  geospatial location data are available.
- No backend/Supabase or AI API changes were made here.
- Actual Flutter compilation and emulator testing have not been performed in
  this environment; the companion browser design preview was interaction-tested.

## Integration plan for the places dataset
After the dataset arrives, replace the sample list with a typed repository
that queries Supabase PostgreSQL. Useful fields: id, name_en, name_ar,
description_en, description_ar, category, city, latitude, longitude,
cover_image_url / Supabase Storage path, historical_story, and publication
status. The UI's search/filter logic can initially run locally; use backend
queries for a larger dataset. Replace the illustrative map with real Mapbox.
Persist favorites in a database table keyed by authenticated user_id/place_id.

## Running
```
cd tourathi
flutter pub get
flutter run -d chrome
```
Click Explore in the bottom navigation, or tap Search / See all from Home.
