# TouRathi — Jordan Tourism Flutter App

TouRathi is a student-built Flutter application showcasing tourism in Jordan. This repository contains the **Flutter app code** for the current graduation-project prototype.

## Current milestone

- ✅ Animated splash screen: centered compass emblem, gold ring, wordmark, automatic transition to Home.
- ✅ Redesigned Home screen: minimal layout with an offline four-destination carousel (Petra, Jerash, Wadi Rum, Dead Sea), autoplay, swipe, page indicators, destination cards, and two shortcuts.
- 🧪 Existing app screens are included from the original starter project as prototypes; they are **not all production-ready**.
- ⏸️ Explore Jordan redesign is on hold pending a new design and the tourism dataset.
- ⏳ Supabase backend, real AI APIs, online maps, and production AR are future integrations; they **are not implemented in this snapshot**.

## Run locally

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) (matching Dart SDK >= 3.7.2) and an emulator or Chrome.
2. Open this folder in VS Code or Android Studio.
3. Run:

```bash
flutter pub get
flutter run -d chrome
```

For Android / iOS devices, use `flutter run` and pick a device. The app launches into the animated splash and proceeds to Home.

## Project layout

- `lib/features/splash/splash_screen.dart` — animated app opening
- `lib/features/home/home_screen.dart` — Home and photo slider
- `lib/features/shell/main_shell.dart` — bottom navigation
- `lib/core/router/app_router.dart` — application routes
- `lib/data/mock/` — temporary sample data
- `assets/images/home/` — four bundled demonstration images

## Images

The four bundled destination images are **AI-generated illustrative placeholders** rather than photos of the actual sites. Replace them with properly licensed authentic photographs before publishing or presenting them as documentary images. Keeping the filenames allows the current Home code to continue working.

## Planned stack

Flutter/Dart frontend; Supabase PostgreSQL / Auth / Storage / Realtime; potential Node.js + Express server layer; third-party AI services and maps. **No backend API credentials belong in this repository.**

## Notes

- This is a prototype and has not been compiled or tested in a Flutter emulator in the preparation environment.
- Do not commit `.env`, API keys, service-role keys, or credentials.
- `README_SPLASH_ANIMATION.md` and `README_HOME_CAROUSEL.md` contain more detailed notes.
