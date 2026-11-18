# TouRathi on Vercel

This repository contains a **Flutter app**, not a Node.js website.
Vercel hosts the compiled Flutter **web** build; it does not deploy Android
or iOS binaries.

## Automatic build

Vercel is connected to `AdamChic04/tourathi` and uses the `main` branch.
`vercel.json` configures:

- Framework preset: Other (`null`)
- Install step: an informational message (Dart packages install in build)
- Build: `bash scripts/vercel-build.sh`
- Output folder: `build/web`
- Routing: serve real static files first; fall back to `index.html`

The build script downloads Flutter stable into a temporary SDK folder and
runs `flutter pub get` and `flutter build web --release`. This can take
several minutes on the first build.

## Supabase

The app's `lib/core/supabase_config.dart` contains only the Supabase project
URL and its **public publishable key**, intended for browser/mobile clients.
Never expose a `service_role` key, secret API key or direct PostgreSQL
credentials in Flutter. The `POSTGRES_*` environment variables Vercel may
have through a separate integration are **not used** by this Flutter app.

For sign-up confirmation and password reset on the deployed website, open
Supabase -> Authentication -> URL Configuration and allow the actual
production URL, e.g. `https://<your-deployment-domain>/**`; keep the
local development and mobile callback URLs as needed.

## Verification

After deployment, load the production URL in a browser. Check the splash
screen, sign-in/sign-up, 61 destination assets, Explore and AI Planner. Test
email confirmation and password recovery separately after Auth redirect
configuration. Do not report email or third-party AI features as live merely
because the Flutter web build succeeds.
