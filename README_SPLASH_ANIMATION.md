# TouRathi — Animated Launch Screen

This build uses the original Flutter project and the previously updated Home screen with its four offline destination images and swipeable image carousel.

## What happens on app launch
1. App starts on `/` in `lib/core/router/app_router.dart`.
2. `lib/features/splash/splash_screen.dart` animates a centered compass-style placeholder mark and TouRathi wordmark. Gold rings rotate, the icon scales into view, and the tagline fades in over a subtle desert backdrop.
3. After about **3.1 seconds**, the animation completes and automatically calls `context.go('/main')`.
4. `MainShell` opens with Home selected (index 0). A short fade/slide page transition makes the handoff feel smooth.
5. The destination carousel on Home continues functioning as before.

## Run it
```bash
flutter pub get
flutter run -d chrome
```

## Files changed
- `lib/features/splash/splash_screen.dart` — replaced original splash with new animated logo splash; auto-navigates to Home.
- `lib/core/router/app_router.dart` — applies a fade/slide to `/main`.

Android and iOS native launch backgrounds are changed from white to warm dark brown to reduce the visible flash before the Flutter animation begins.

**No feature screens or database integration were changed.** `/onboarding` is retained in the router but not used as the first page of the demo.

Note: The original uploaded app did not have a dedicated TouRathi logo image asset; its splash used a gold compass icon and the TouRathi wordmark, which are retained and animated here. If an official logo is supplied later, it can replace the `Icons.explore_rounded` mark.

## Logo alignment update
The compass mark is now centered precisely both vertically and horizontally on the splash screen. The TouRathi name and tagline appear below it; the loading bar is anchored separately near the bottom. Original project includes NO official TouRathi image logo asset: Android app icon is the default Flutter logo. To use an official logo later, supply its PNG/SVG file and replace the compass widget in `lib/features/splash/splash_screen.dart`.
