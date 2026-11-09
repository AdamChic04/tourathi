/// Deterministic demo planner. It deliberately makes no live AI, routing,
/// opening-hours, or price claims; replace the repository with the Node API
/// before using this with real travelers.
enum DiscoveryPreference { famous, local, mixed }

class TripPreferences {
  const TripPreferences({
    required this.days,
    required this.budgetFils,
    required this.interests,
    required this.discovery,
    this.maxWalkingKm = 8,
    this.avoidCrowds = false,
  });

  final int days;
  final int budgetFils;
  final Set<String> interests;
  final DiscoveryPreference discovery;
  final double maxWalkingKm;
  final bool avoidCrowds;
}

class DemoDestination {
  const DemoDestination({
    required this.id,
    required this.name,
    required this.city,
    required this.category,
    required this.discovery,
    required this.costFils,
    required this.visitMinutes,
    required this.walkingKm,
    required this.source,
  });

  final String id;
  final String name;
  final String city;
  final String category;
  final DiscoveryPreference discovery;
  final int? costFils;
  final int visitMinutes;
  final double? walkingKm;
  final String source;
}

class PlannedVisit {
  const PlannedVisit(this.destination, this.reason);
  final DemoDestination destination;
  final String reason;
}

class DemoPlan {
  const DemoPlan({
    required this.visits,
    required this.totalFils,
    required this.warnings,
  });
  final List<PlannedVisit> visits;
  final int totalFils;
  final List<String> warnings;
  bool get valid => visits.isNotEmpty && totalFils <= 0x7fffffff;
}

const demoDestinations = <DemoDestination>[
  DemoDestination(
    id: 'petra',
    name: 'Petra',
    city: 'Ma’an',
    category: 'heritage',
    discovery: DiscoveryPreference.famous,
    costFils: null,
    visitMinutes: 240,
    walkingKm: null,
    source: 'Demo fixture; verify current fees, hours and accessibility',
  ),
  DemoDestination(
    id: 'jerash',
    name: 'Jerash Archaeological City',
    city: 'Jerash',
    category: 'heritage',
    discovery: DiscoveryPreference.famous,
    costFils: null,
    visitMinutes: 180,
    walkingKm: null,
    source: 'Demo fixture; verify current fees, hours and accessibility',
  ),
  DemoDestination(
    id: 'salt-walk',
    name: 'As-Salt heritage walk',
    city: 'Balqa',
    category: 'culture',
    discovery: DiscoveryPreference.local,
    costFils: null,
    visitMinutes: 120,
    walkingKm: null,
    source: 'Demo fixture; verify with local organizer',
  ),
  DemoDestination(
    id: 'madaba-crafts',
    name: 'Madaba craft experience',
    city: 'Madaba',
    category: 'culture',
    discovery: DiscoveryPreference.local,
    costFils: null,
    visitMinutes: 90,
    walkingKm: null,
    source: 'Demo fixture; verify availability with host',
  ),
  DemoDestination(
    id: 'wadi-rum',
    name: 'Wadi Rum',
    city: 'Aqaba',
    category: 'nature',
    discovery: DiscoveryPreference.mixed,
    costFils: null,
    visitMinutes: 240,
    walkingKm: null,
    source: 'Demo fixture; requires verified operator and booking',
  ),
];

DemoPlan buildDemoPlan(
  TripPreferences preferences, {
  List<DemoDestination> candidates = demoDestinations,
}) {
  if (preferences.days < 1 || preferences.days > 30) {
    return const DemoPlan(
      visits: [],
      totalFils: 0,
      warnings: ['Trip length must be between 1 and 30 days.'],
    );
  }
  final pool =
      candidates
          .where(
            (place) =>
                (preferences.interests.isEmpty ||
                    preferences.interests.contains(place.category)) &&
                (place.walkingKm == null ||
                    place.walkingKm! <= preferences.maxWalkingKm),
          )
          .toList();
  pool.sort((a, b) {
    final ap = a.discovery == preferences.discovery ? 1 : 0;
    final bp = b.discovery == preferences.discovery ? 1 : 0;
    return bp.compareTo(ap);
  });
  final visits = <PlannedVisit>[];
  var total = 0;
  for (final place in pool) {
    // Unknown prices are never treated as free and cannot pass a hard budget.
    if (place.costFils == null) continue;
    if (total + place.costFils! > preferences.budgetFils) continue;
    visits.add(
      PlannedVisit(
        place,
        'Matches your selected interests and discovery preference.',
      ),
    );
    total += place.costFils!;
    if (visits.length >= preferences.days * 3) break;
  }
  final warnings = <String>[
    'DEMO DATA: no verified live opening hours, prices, routes, availability, or accessibility information.',
    if (visits.isEmpty)
      'No destinations with known demo prices fit the selected preferences and budget.',
    if (preferences.avoidCrowds)
      'Crowd levels are unknown; no quiet-place guarantee is made.',
    'This prototype does not call OpenAI, Mapbox, or Firestore and is not a verified itinerary.',
  ];
  return DemoPlan(
    visits: List.unmodifiable(visits),
    totalFils: total,
    warnings: List.unmodifiable(warnings),
  );
}
