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
  test('planner only schedules places with verified price records', () async {
    final result = await TripPlanGenerator().generate(preferences());
    final ids = result.days
        .expand((day) => day.places)
        .map((place) => place.id)
        .toList();
    expect(ids, isNotEmpty);
    expect(ids.toSet().length, ids.length);
    expect(
      ids.every((id) => JordanPriceCatalog.forPlaceId(id).isVerified),
      isTrue,
    );
  });

  test('a place with no published admission price is excluded', () async {
    final result = await TripPlanGenerator().generate(preferences(
      destination: 'Balqa',
      budget: 1,
      days: 1,
      pace: 'relaxed',
      interests: {'nature'},
      discovery: 'mixed',
    ));
    final ids = result.days.expand((day) => day.places).map((p) => p.id).toList();
    expect(ids, isNot(contains('balqa-wadi-shuaib')));
    expect(
      JordanPriceCatalog.forPlaceId('balqa-wadi-shuaib').isVerified,
      isFalse,
    );
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
    // cannot silently be marked free.
    expect(result.estimatedLow <= 1, isTrue);
    expect(
      result.days
          .expand((day) => day.places)
          .every((place) => JordanPriceCatalog.forPlaceId(place.id).isVerified),
      isTrue,
    );
  });
}
