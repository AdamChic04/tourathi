import 'package:flutter_test/flutter_test.dart';
import 'package:tourathi/features/ai_planner/trip_plan_generator.dart';
import 'package:tourathi/features/ai_planner/jordan_price_catalog.dart';

PlannerPreferences preferences({
  String destination = 'Jordan',
  double budget = 100000,
  int days = 30,
  Set<String> interests = const <String>{},
  String discovery = 'mixed',
  String pace = 'active',
}) => PlannerPreferences(
  destination: destination,
  budget: budget,
  travelers: 1,
  days: days,
  interests: interests,
  pace: pace,
  discovery: discovery,
  visitorClass: VisitorRateClass.international,
);

void main() {
  test('all 61 Jordan destinations can be scheduled without a price gate', () async {
    final result = await TripPlanGenerator().generate(preferences());
    final ids = result.days
        .expand((day) => day.places)
        .map((place) => place.id)
        .toList();
    expect(ids.length, 61);
    expect(ids.toSet().length, 61);
    expect(result.hasUnknownCosts, isTrue);
    expect(result.unpricedPlaceIds, isNotEmpty);
    expect(result.suggestedBudget, 0); // Unknown costs cannot yield full quote.
  });

  test('a place with no published admission price can still be recommended', () async {
    final result = await TripPlanGenerator().generate(preferences(
      destination: 'Balqa',
      budget: 1,
      days: 1,
      pace: 'relaxed',
      interests: {'nature'},
      discovery: 'mixed',
    ));
    final ids = result.days.expand((day) => day.places).map((p) => p.id).toList();
    expect(ids, contains('balqa-wadi-shuaib'));
    expect(result.unpricedPlaceIds, contains('balqa-wadi-shuaib'));
    // Zero here is the KNOWN fee subtotal, not a claim of free entry.
    expect(result.estimatedLow, 0);
    expect(result.estimatedHigh, 0);
    expect(result.hasUnknownCosts, isTrue);
  });

  test('known published fees remain budget-gated', () async {
    final result = await TripPlanGenerator().generate(preferences(
      destination: 'Amman',
      budget: 1,
      days: 2,
      interests: {'culture'},
      discovery: 'mixed',
      pace: 'active',
    ));
    // When the remaining activity budget is too small, known fee-based stops
    // cannot silently be marked free. Unpriced places are provisional only.
    expect(result.estimatedLow <= 1, isTrue);
    expect(result.unpricedPlaceIds.toSet().length,
        result.unpricedPlaceIds.length);
  });
}
