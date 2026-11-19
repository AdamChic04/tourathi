import 'package:shared_preferences/shared_preferences.dart';

/// Clearly marked, local-only preview accounts. These never create or alter a
/// Supabase account and are not a substitute for production authorization.
class DemoSession {
  DemoSession._();
  static const _key = 'tourathi_demo_role';
  static String? role;

  static Future<void> restore() async {
    role = (await SharedPreferences.getInstance()).getString(_key);
  }

  static Future<void> enter(String value) async {
    role = value;
    await (await SharedPreferences.getInstance()).setString(_key, value);
  }

  static Future<void> leave() async {
    role = null;
    await (await SharedPreferences.getInstance()).remove(_key);
  }
}
