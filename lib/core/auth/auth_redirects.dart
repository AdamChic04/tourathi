import 'package:flutter/foundation.dart';

/// Add these URLs to Supabase > Authentication > URL Configuration >
/// Redirect URLs before testing verification or password recovery.
/// http://localhost:*/** (local Flutter web development)
/// tourathi://auth-callback (Android / iOS)
class AuthRedirects {
  AuthRedirects._();

  static String get callback =>
      kIsWeb ? Uri.base.origin : 'tourathi://auth-callback';

  static String get passwordReset => kIsWeb
      ? '${Uri.base.origin}/#/reset-password'
      : 'tourathi://auth-callback/reset-password';
}
