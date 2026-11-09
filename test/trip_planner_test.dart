import 'package:flutter_test/flutter_test.dart';
import 'package:tourathi/features/ai_planner/trip_planner.dart';

void main() {
  test('does not treat unknown destination prices as free', () {
    final plan = buildDemoPlan(const TripPreferences(
      days: 2,
      budgetFils: 100000,
      interests: {'heritage'},
      discovery: DiscoveryPreference.famous,
    ));
    expect(plan.visits, isEmpty);
    expect(plan.warnings.any((warning) => warning.contains('known demo prices')), isTrue);
  });

  test('rejects invalid trip lengths', () {
    final plan = buildDemoPlan(const TripPreferences(
      days: 0,
      budgetFils: 100000,
      interests: {},
      discovery: DiscoveryPreference.mixed,
    ));
    expect(plan.visits, isEmpty);
    expect(plan.warnings.single, contains('between 1 and 30'));
  });

  test('ranks selected discovery preference before other styles', () {
    const places = [
      DemoDestination(id: 'famous', name: 'Famous', city: 'Amman', category: 'culture', discovery: DiscoveryPreference.famous, costFils: 1000, visitMinutes: 60, walkingKm: 1, source: 'test'),
      DemoDestination(id: 'local', name: 'Local', city: 'Salt', category: 'culture', discovery: DiscoveryPreference.local, costFils: 1000, visitMinutes: 60, walkingKm: 1, source: 'test'),
    ];
    final plan = buildDemoPlan(const TripPreferences(
      days: 1,
      budgetFils: 10000,
      interests: {'culture'},
      discovery: DiscoveryPreference.local,
    ), candidates: places);
    expect(plan.visits.first.destination.id, 'local');
  });
}
