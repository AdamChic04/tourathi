import 'package:flutter_test/flutter_test.dart';
import 'package:tourathi/core/supabase_config.dart';

void main() {
  test('Supabase public client configuration points to the TouRathi project', () {
    expect(Uri.parse(SupabaseConfig.url).scheme, 'https');
    expect(SupabaseConfig.publishableKey.startsWith('sb_publishable_'), isTrue);
  });
}
