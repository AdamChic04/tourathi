# TouRathi — Simple Home UI (November 2026)

This Flutter implementation updates **only** `lib/features/home/home_screen.dart` in the existing TouRathi app. The centered animated splash is unchanged, and the Explore Jordan redesign is **not included**.

## Home design

- Minimal sandstone/ivory theme, with dark-mode and Arabic text support.
- Clean wordmark, headline and simple Search shortcut.
- Large **4-slide PageView** with bundled offline visuals; auto-advances every 5 seconds, supports swipe and tappable indicators.
- Tapping a hero image or destination card opens its existing `/place/:id` details route.
- AI Trip Planner opens `/ai-planner`; Search and See All select the Explore bottom tab using `onSelectTab(1)`.
- Popular destination cards have locally toggled favorites (not yet connected to Supabase).
- Compact shortcuts open `/ar-hub` and `/social-journal`.
- MainShell retains all five tabs; its floating AI button is hidden on Home only, since the Home screen already has a trip planner card.

## Run locally

```bash
flutter pub get
flutter run -d chrome
```

The four files in `assets/images/home/` are **AI-generated demonstration visuals**, not authentic tourism photography. Swap with appropriately licensed photos before a public release.

## Verification

Assets and route names checked against the project, HTML layout preview tested in Chromium; Flutter build has **not** been run here because the Flutter SDK is unavailable. 
