# TouRathi — Authentication Setup

## Supabase project

- Project: [TouRathi dashboard](https://supabase.com/dashboard/project/nxzqoncpesywoahscpwq)
- Database region: Frankfurt (`eu-central-1`)
- Flutter client configuration: `lib/core/supabase_config.dart`
- Client uses a **publishable** key with Row Level Security. **Never** commit a Supabase secret/service-role key.

## One-time URL Configuration (required for email links)

In **Supabase Dashboard → Authentication → URL Configuration → Redirect URLs**, add:

- `http://localhost:5173/**` (Flutter web development)
- `http://127.0.0.1:5173/**` (alternate browser hostname)
- `tourathi://auth-callback` (Android / iOS email verification callback)
- `tourathi://auth-callback/**` (Android / iOS password recovery)

When deploying Flutter web to a real domain, also add `https://your-domain.example/**`. Keep the domain you actually control, not the example. For a hosted web app, update **Site URL** to that app's real URL.

Email/password authentication and signup confirmation must be enabled in **Authentication → Providers → Email**. Supabase's built-in email service has test limits; before public launch, configure your own SMTP provider and account for deliverability.

## Run

```powershell
flutter pub get
flutter run -d chrome --web-port=5173
```

The first app launch shows the 3-second animated splash. After that:
1. Sign up with full name, email and password.
2. Confirm the email sent by Supabase.
3. Sign in using your verified email and password.
4. Open the account icon on Home to view your account or sign out.
5. Use **Forgot password?** to request a reset link; the reset form changes the password and signs out.

Passwords are never stored in public profile tables. Supabase Auth handles authentication. The `profiles` and `account_roles` tables are created by the migration `supabase/migrations/20261111_create_tourathi_auth_profiles_and_roles.sql` (already applied to this project).

## Security and user types

- All public sign-ups are **tourists**, regardless of metadata supplied by the client.
- `account_roles` has Row Level Security and no public UPDATE/INSERT policy.
- Organizer, seller, and admin approvals and dashboards are **not yet implemented**.
- Never add a public role selector that lets someone register as an admin.
- The linked project key is *publishable*, not secret; RLS protects user data.

## Testing

The web application can be compiled using `flutter build web`. Verify email confirmation and password reset with a real inbox after adding the Redirect URLs. The mobile deep-link flows require Android/iOS device testing.

If you later create a new Supabase project, update the project URL and publishable key in `lib/core/supabase_config.dart`, and apply the migration to that new project.
