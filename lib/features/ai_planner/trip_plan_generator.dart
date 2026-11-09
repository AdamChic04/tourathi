import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/mock/jordan_place_seed.dart';
import '../../data/models/models.dart';
import 'jordan_price_catalog.dart';
import 'jordan_visit_info.dart';

const _deviceIdKey = 'tourathi.ai_planner.install_id';

class PlannerPreferences {
  const PlannerPreferences({
    required this.destination,
    required this.budget,
    required this.travelers,
    required this.days,
    required this.interests,
    required this.pace,
    required this.discovery,
    required this.visitorClass,
    this.travelDate = '',
    this.startLocation = 'Amman',
    this.mobilityNeeds = '',
    this.accessibilityNeeds = '',
    this.dietaryNeeds = '',
    this.additionalRequests = '',
    this.currentPlanIds = const [],
    this.otherCostsAllowance = 0,
    this.conversationHistory = const [],
    this.language = 'en',
  });

  final String destination;
  final double budget;
  final int travelers;
  final int days;
  final Set<String> interests;
  final String pace;
  final String discovery;
  final VisitorRateClass visitorClass;
  final String travelDate;
  final String startLocation;
  final String mobilityNeeds;
  final String accessibilityNeeds;
  final String dietaryNeeds;
  final String additionalRequests;
  final List<List<String>> currentPlanIds;
  final double otherCostsAllowance;
  final List<Map<String, String>> conversationHistory;
  final String language;

  double get activityBudget => max(0, budget - otherCostsAllowance);
  double get mealReserveLow =>
      destination == 'Amman' ? (3 * 3 * days * travelers).toDouble() : 0.0;
  double get budgetForActivities => max(0, activityBudget - mealReserveLow);

  int get stopsPerDay => switch (pace) {
    'relaxed' => 2,
    'active' => 4,
    _ => 3,
  };

  Map<String, Object?> toJson() => {
    'destination': destination,
    'budget': budget,
    'activityBudget': activityBudget,
    'budgetForActivities': budgetForActivities,
    'mealReserveLow': mealReserveLow,
    'otherCostsAllowance': otherCostsAllowance,
    'travelers': travelers,
    'days': days,
    'interests': interests.toList(),
    'pace': pace,
    'discovery': discovery,
    'visitorClass': visitorClass.name,
    'travelDate': travelDate,
    'startLocation': startLocation,
    'mobilityNeeds': mobilityNeeds,
    'accessibilityNeeds': accessibilityNeeds,
    'dietaryNeeds': dietaryNeeds,
    'additionalRequests': additionalRequests,
    'currentPlan': currentPlanIds,
    'conversationHistory': conversationHistory,
    'language': language,
  };
}

class GeneratedPlanDay {
  const GeneratedPlanDay(this.region, this.places);
  final String region;
  final List<Place> places;
}

class PlanGenerationResult {
  const PlanGenerationResult({
    required this.days,
    required this.estimatedLow,
    required this.estimatedHigh,
    required this.suggestedBudget,
    required this.usedAi,
    required this.statusMessage,
    required this.preferences,
    required this.explanation,
    required this.placeReasons,
    this.alternatives = const [],
  });

  final List<GeneratedPlanDay> days;
  final double estimatedLow;
  final double estimatedHigh;
  final double suggestedBudget;
  final bool usedAi;
  final String statusMessage;
  final PlannerPreferences preferences;
  final String explanation;
  final Map<String, String> placeReasons;
  final List<Place> alternatives;
}

class _AiProposal {
  const _AiProposal({
    required this.days,
    required this.explanation,
    required this.reasons,
  });
  final List<List<String>> days;
  final String explanation;
  final Map<String, String> reasons;
}

class TripPlanGenerator {
  TripPlanGenerator({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _endpoint = String.fromEnvironment('AI_PLANNER_API_URL');

  Future<PlanGenerationResult> generate(PlannerPreferences preferences) async {
    final eligible = _eligiblePlaces(preferences);
    if (eligible.isEmpty) {
      return _emptyResult(
        preferences,
        'No priced catalog places match these preferences.',
      );
    }

    _AiProposal? proposal;
    String fallbackReason =
        'AI service is not configured; used the on-device planner.';
    if (_endpoint.trim().isNotEmpty) {
      try {
        proposal = await _requestAi(preferences, eligible);
        fallbackReason = '';
      } catch (error) {
        fallbackReason = _friendlyError(error);
      }
    }

    final List<GeneratedPlanDay> scheduled =
        proposal == null
            ? _buildLocalPlan(preferences, eligible)
            : _fitSchedule(preferences, eligible, proposal.days);
    if (scheduled.isEmpty) {
      return _emptyResult(
        preferences,
        fallbackReason.isEmpty
            ? 'No catalog places fit the entered budget.'
            : fallbackReason,
      );
    }

    final amounts = _totals(scheduled, preferences);
    return PlanGenerationResult(
      days: List.unmodifiable(scheduled),
      estimatedLow: amounts.$1,
      estimatedHigh: amounts.$2,
      suggestedBudget: max(amounts.$1, amounts.$2),
      usedAi: proposal != null,
      statusMessage:
          proposal != null
              ? 'Itinerary order generated by Cloudflare Workers AI from the project catalog.'
              : fallbackReason,
      preferences: preferences,
      explanation:
          proposal == null
              ? 'Built from the project place catalog using matching categories and official or published price records. Live hours and route information are unavailable for most locations.'
              : proposal.explanation,
      placeReasons:
          proposal == null
              ? _localReasons(scheduled, preferences)
              : proposal.reasons,
    );
  }

  List<Place> _eligiblePlaces(PlannerPreferences preferences) {
    final categories = <String, Set<String>>{
      'culture': {'heritage', 'museums', 'religious'},
      'nature': {'hiking'},
      'adventure': {'adventure', 'hiking'},
      'food': {'food'},
      'history': {'heritage', 'religious', 'museums'},
      'religious': {'religious'},
      'shopping': {'food'},
    };
    final requested =
        preferences.interests
            .expand((interest) => categories[interest] ?? const <String>{})
            .toSet();
    final all =
        JordanPlaceSeed.places.where((place) {
          final destinationMatches =
              preferences.destination == 'Jordan' ||
              place.location
                      .split(',')
                      .first
                      .trim()
                      .replaceFirst(' Governorate', '') ==
                  preferences.destination;
          final interestMatches =
              requested.isEmpty || requested.contains(place.category);
          final discoveryMatches = switch (preferences.discovery) {
            'famous' => place.discoveryTier == 'famous',
            'local' => place.discoveryTier != 'famous',
            _ => true,
          };
          return destinationMatches && interestMatches && discoveryMatches;
        }).toList();
    // Unknown prices are never treated as free and cannot be budget-fitted.
    final priced =
        all
            .where(
              (place) => JordanPriceCatalog.forPlaceId(place.id).isVerified,
            )
            .toList();
    priced.sort(
      (a, b) => _score(b, preferences).compareTo(_score(a, preferences)),
    );
    return priced;
  }

  int _score(Place place, PlannerPreferences preferences) {
    var score = 0;
    if (preferences.interests.any(
      (interest) => (switch (interest) {
        'culture' || 'history' => {'heritage', 'museums', 'religious'},
        'nature' => {'hiking'},
        'adventure' => {'adventure', 'hiking'},
        'food' || 'shopping' => {'food'},
        'religious' => {'religious'},
        _ => <String>{},
      }).contains(place.category),
    )) {
      score += 8;
    }
    if (preferences.discovery == 'mixed') {
      score += place.discoveryTier == 'famous' ? 2 : 3;
    }
    if (preferences.discovery == 'famous' && place.discoveryTier == 'famous') {
      score += 5;
    }
    if (preferences.discovery == 'local' && place.discoveryTier != 'famous') {
      score += 5;
    }
    if (place.category == 'heritage') score += 2;
    return score;
  }

  Future<_AiProposal> _requestAi(
    PlannerPreferences preferences,
    List<Place> places,
  ) async {
    final deviceId = await _installId();
    final payload = {
      ...preferences.toJson(),
      'maxStopsPerDay': preferences.stopsPerDay,
      'deviceId': deviceId,
      'places':
          places.map((place) {
            final price = JordanPriceCatalog.forPlaceId(place.id);
            final visit = JordanVisitInfoCatalog.forPlace(
              place.id,
              visitDate: DateTime.tryParse(preferences.travelDate),
            );
            final low = _unitLow(price, preferences.visitorClass);
            final high = _unitHigh(price, preferences.visitorClass);
            return {
              'id': place.id,
              'name': place.name,
              'region': place.location.split(',').first.trim(),
              'category': place.category,
              'discoveryTier': place.discoveryTier,
              'costLow': low,
              'costHigh': high,
              'priceLabel': '${price.label}; ${price.conditions}',
              'priceSource': price.sourceName,
              'priceSourceUrl': price.sourceUrl,
              'priceCheckedAt': price.checkedAt,
              'openingHours': visit?.hours ?? 'not verified',
              'openingHoursSource': visit?.sourceName ?? '',
              'openingHoursSourceUrl': visit?.sourceUrl ?? '',
              'openingHoursCheckedAt': visit?.checkedAt ?? '',
              'accessConditions':
                  visit?.conditions ?? 'not verified; confirm with venue',
            };
          }).toList(),
    };
    final response = await _client
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'X-Tourathi-Device': deviceId,
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 35));
    if (response.statusCode != 200) {
      throw _PlannerApiException(response.statusCode, response.body);
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map || decoded['days'] is! List) {
      throw const FormatException(
        'The AI service returned an invalid itinerary.',
      );
    }
    final validIds = places.map((place) => place.id).toSet();
    final used = <String>{};
    final groups = <List<String>>[];
    for (final day in decoded['days'] as List) {
      if (day is! Map || day['placeIds'] is! List) continue;
      final ids =
          (day['placeIds'] as List)
              .whereType<String>()
              .where((id) => validIds.contains(id) && used.add(id))
              .take(preferences.stopsPerDay)
              .toList();
      if (ids.isNotEmpty) groups.add(ids);
      if (groups.length >= preferences.days) break;
    }
    if (groups.isEmpty) {
      throw const FormatException(
        'The AI did not return usable catalog places.',
      );
    }
    final rawReasons = decoded['reasons'];
    final reasons = <String, String>{};
    if (rawReasons is Map) {
      for (final entry in rawReasons.entries) {
        if (entry.key is String &&
            entry.value is String &&
            validIds.contains(entry.key)) {
          reasons[entry.key as String] = (entry.value as String).substring(
            0,
            (entry.value as String).length.clamp(0, 240),
          );
        }
      }
    }
    final explanation =
        decoded['explanation'] is String
            ? (decoded['explanation'] as String).substring(
              0,
              (decoded['explanation'] as String).length.clamp(0, 600),
            )
            : 'Plan tailored to your travel details and the verified project catalog.';
    return _AiProposal(
      days: groups,
      explanation: explanation,
      reasons: reasons,
    );
  }

  Map<String, String> _localReasons(
    List<GeneratedPlanDay> days,
    PlannerPreferences preferences,
  ) => {
    for (final place in days.expand((day) => day.places))
      place.id:
          preferences.interests.isEmpty
              ? 'Selected from the available priced catalog for your destination and budget.'
              : 'Matches your ${preferences.interests.join(', ')} interest selection and available price data.',
  };

  Future<String> _installId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.length >= 12) return existing;
    final random = Random.secure();
    final id =
        '${DateTime.now().microsecondsSinceEpoch}_${List<int>.generate(16, (_) => random.nextInt(16)).map((digit) => digit.toRadixString(16)).join()}';
    await prefs.setString(_deviceIdKey, id);
    return id;
  }

  List<List<String>> _buildLocalSchedule(
    PlannerPreferences preferences,
    List<Place> places,
  ) {
    final remaining = [...places];
    final schedule = <List<String>>[];
    var spent = 0.0;
    for (
      var dayIndex = 0;
      dayIndex < preferences.days && remaining.isNotEmpty;
      dayIndex++
    ) {
      final regionScores = <String, int>{};
      for (final place in remaining) {
        final region = place.location.split(',').first.trim();
        regionScores[region] =
            (regionScores[region] ?? 0) + _score(place, preferences);
      }
      final region =
          regionScores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      final dayPlaces = <String>[];
      for (final place
          in remaining
              .where((p) => p.location.split(',').first.trim() == region)
              .toList()) {
        if (dayPlaces.length >= preferences.stopsPerDay) break;
        final next =
            _personCostLow(place, preferences.visitorClass) *
            preferences.travelers;
        if (spent + next > preferences.budgetForActivities) continue;
        dayPlaces.add(place.id);
        spent += next;
        remaining.remove(place);
      }
      if (dayPlaces.isNotEmpty) {
        schedule.add(dayPlaces);
      } else {
        break;
      }
    }
    return schedule;
  }

  List<GeneratedPlanDay> _buildLocalPlan(
    PlannerPreferences preferences,
    List<Place> places,
  ) {
    final byId = {for (final place in places) place.id: place};
    return _buildLocalSchedule(preferences, places).map((ids) {
      final selected = ids.map((id) => byId[id]!).toList();
      return GeneratedPlanDay(
        selected.first.location.split(',').first.trim(),
        List.unmodifiable(selected),
      );
    }).toList();
  }

  List<GeneratedPlanDay> _fitSchedule(
    PlannerPreferences preferences,
    List<Place> places,
    List<List<String>> proposed,
  ) {
    final byId = {for (final place in places) place.id: place};
    final result = <GeneratedPlanDay>[];
    var spent = 0.0;
    for (final ids in proposed.take(preferences.days)) {
      final selected = <Place>[];
      for (final id in ids.take(preferences.stopsPerDay)) {
        final place = byId[id];
        if (place == null) continue;
        final cost =
            _personCostLow(place, preferences.visitorClass) *
            preferences.travelers;
        if (spent + cost > preferences.budgetForActivities) continue;
        selected.add(place);
        spent += cost;
      }
      if (selected.isNotEmpty) {
        result.add(
          GeneratedPlanDay(
            selected.first.location.split(',').first.trim(),
            List.unmodifiable(selected),
          ),
        );
      }
    }
    if (result.isEmpty) return _buildLocalPlan(preferences, places);
    return result;
  }

  (double, double) _totals(
    List<GeneratedPlanDay> days,
    PlannerPreferences preferences,
  ) {
    var low = 0.0;
    var high = 0.0;
    for (final day in days) {
      for (final place in day.places) {
        final estimate = JordanPriceCatalog.forPlaceId(place.id);
        low +=
            _unitLow(estimate, preferences.visitorClass) *
            preferences.travelers;
        high +=
            _unitHigh(estimate, preferences.visitorClass) *
            preferences.travelers;
      }
    }
    return (low, high);
  }

  double _unitLow(PriceEstimate estimate, VisitorRateClass visitorClass) =>
      estimate.forVisitor(visitorClass) ?? estimate.low ?? 0;

  double _unitHigh(PriceEstimate estimate, VisitorRateClass visitorClass) =>
      estimate.high ?? estimate.forVisitor(visitorClass) ?? estimate.low ?? 0;

  double _personCostLow(Place place, VisitorRateClass visitorClass) =>
      _unitLow(JordanPriceCatalog.forPlaceId(place.id), visitorClass);

  PlanGenerationResult _emptyResult(
    PlannerPreferences preferences,
    String message,
  ) => PlanGenerationResult(
    days: const [],
    estimatedLow: 0,
    estimatedHigh: 0,
    suggestedBudget:
        _cheapestKnown(preferences) +
        preferences.otherCostsAllowance +
        preferences.mealReserveLow,
    usedAi: false,
    statusMessage: message,
    preferences: preferences,
    explanation: message,
    placeReasons: const {},
    alternatives: _alternatives(preferences),
  );

  List<Place> _alternatives(PlannerPreferences preferences) {
    if (preferences.destination == 'Jordan') return const [];
    final broad = PlannerPreferences(
      destination: 'Jordan',
      budget: preferences.budget,
      travelers: preferences.travelers,
      days: preferences.days,
      interests: preferences.interests,
      pace: preferences.pace,
      discovery: 'mixed',
      visitorClass: preferences.visitorClass,
      travelDate: preferences.travelDate,
      startLocation: preferences.startLocation,
      mobilityNeeds: preferences.mobilityNeeds,
      accessibilityNeeds: preferences.accessibilityNeeds,
      dietaryNeeds: preferences.dietaryNeeds,
      additionalRequests: preferences.additionalRequests,
      otherCostsAllowance: preferences.otherCostsAllowance,
    );
    return _eligiblePlaces(broad).take(4).toList(growable: false);
  }

  double _cheapestKnown(PlannerPreferences preferences) {
    final places = _eligiblePlaces(preferences);
    if (places.isEmpty) return 0;
    return places
        .map(
          (place) =>
              _personCostLow(place, preferences.visitorClass) *
              preferences.travelers,
        )
        .reduce(min);
  }

  String _friendlyError(Object error) {
    if (error is _PlannerApiException) {
      if (error.statusCode == 429) {
        return 'AI daily quota or rate limit reached; used the on-device planner.';
      }
      if (error.statusCode == 404 || error.statusCode == 503) {
        return 'AI service is unavailable; used the on-device planner.';
      }
      return 'AI service returned an error; used the on-device planner.';
    }
    if (error is FormatException) {
      return 'AI response was not valid; used the on-device planner.';
    }
    if (error.toString().contains('TimeoutException')) {
      return 'AI service timed out; used the on-device planner.';
    }
    return 'Could not reach the AI service; used the on-device planner.';
  }
}

class _PlannerApiException implements Exception {
  const _PlannerApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;
}
