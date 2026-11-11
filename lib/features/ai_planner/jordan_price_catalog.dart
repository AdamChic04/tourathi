import '../../data/mock/jordan_place_seed.dart';
import '../../data/repositories/place_visit_facts_repository.dart';

enum VisitorRateClass { jordanian, resident, international, internationalDayVisitor }

enum PriceConfidence {
  officialFixed,
  publishedMarket,
  marketEstimate,
  notVerified,
}

class PriceEstimate {
  const PriceEstimate({
    required this.id,
    required this.label,
    required this.unit,
    required this.confidence,
    required this.sourceName,
    required this.sourceUrl,
    required this.checkedAt,
    required this.conditions,
    this.jordanian,
    this.resident,
    this.international,
    this.dayVisitor,
    this.low,
    this.high,
  });

  final String id;
  final String label;
  final String unit;
  final PriceConfidence confidence;
  final String sourceName;
  final String sourceUrl;
  final String checkedAt;
  final String conditions;
  final double? jordanian;
  final double? resident;
  final double? international;
  final double? dayVisitor;
  final double? low;
  final double? high;

  bool get isVerified => confidence != PriceConfidence.notVerified;

  double? forVisitor(VisitorRateClass visitorClass) => switch (visitorClass) {
    VisitorRateClass.jordanian => jordanian ?? low,
    VisitorRateClass.resident => resident ?? international ?? low,
    VisitorRateClass.international => international ?? low,
    VisitorRateClass.internationalDayVisitor =>
      dayVisitor ?? international ?? low,
  };

  Map<String, Object?> toJson() => {
    'id': id,
    'label': label,
    'unit': unit,
    'confidence': confidence.name,
    'sourceName': sourceName,
    'sourceUrl': sourceUrl,
    'checkedAt': checkedAt,
    'conditions': conditions,
    'jordanian': jordanian,
    'resident': resident,
    'international': international,
    'dayVisitor': dayVisitor,
    'low': low,
    'high': high,
  };

  factory PriceEstimate.fromJson(Map<String, Object?> json) => PriceEstimate(
    id: json['id'] as String? ?? '',
    label: json['label'] as String? ?? '',
    unit: json['unit'] as String? ?? 'per person',
    confidence: PriceConfidence.values.firstWhere(
      (value) => value.name == json['confidence'],
      orElse: () => PriceConfidence.notVerified,
    ),
    sourceName: json['sourceName'] as String? ?? '',
    sourceUrl: json['sourceUrl'] as String? ?? '',
    checkedAt: json['checkedAt'] as String? ?? '',
    conditions: json['conditions'] as String? ?? '',
    jordanian: (json['jordanian'] as num?)?.toDouble(),
    resident: (json['resident'] as num?)?.toDouble(),
    international: (json['international'] as num?)?.toDouble(),
    dayVisitor: (json['dayVisitor'] as num?)?.toDouble(),
    low: (json['low'] as num?)?.toDouble(),
    high: (json['high'] as num?)?.toDouble(),
  );
}

/// Research snapshot checked on 2026-11-07. Official schedules and market
/// estimates are kept distinct. Unmatched seed places are explicitly unpriced.
class JordanPriceCatalog {
  JordanPriceCatalog._();

  static const checkedAt = '2026-11-07';
  static const tourismFeesUrl =
      'https://international.visitjordan.com/page/17/entrance-fees/';
  static const petraFeesUrl = 'https://visitpetra.jo/en/Petrafees';
  static const jordanPassUrl = 'https://www.jordanpass.jo/contents/Prices.aspx';
  static const rscn2026Url =
      'https://www.rscn.org.jo/uploaded_files/reservation/Dana%20Biosphere%20Reserve%20Trails%202026.pdf';
  static const numbeoAmmanUrl =
      'https://www.numbeo.com/cost-of-living/in/Amman';
  static const airportUrl =
      'https://international.visitjordan.com/page/7/airports/';
  static const wadiRumOperatorUrl =
      'https://wadirum-jordan.com/4-hour-jeep-tour-of-wadi-rum';

  static const _officialFees = <PriceEstimate>[
    PriceEstimate(
      id: 'roman-theatre',
      label: 'Roman Theatre and museum',
      unit: 'per person',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board entrance-fee schedule',
      sourceUrl: tourismFeesUrl,
      checkedAt: checkedAt,
      conditions:
          'Listed Roman Theater/museum package; adult rates vary by citizenship.',
      jordanian: .25,
      international: 2,
    ),
    PriceEstimate(
      id: 'amman-citadel',
      label: 'Amman Citadel',
      unit: 'per person',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board entrance-fee schedule',
      sourceUrl: tourismFeesUrl,
      checkedAt: checkedAt,
      conditions: 'Adult admission; listed Jordanian and foreigner rates.',
      jordanian: .25,
      international: 3,
    ),
    PriceEstimate(
      id: 'amman-iraq-al-amir',
      label: 'Iraq Al Amir',
      unit: 'per person',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board entrance-fee schedule',
      sourceUrl: tourismFeesUrl,
      checkedAt: checkedAt,
      conditions:
          'Adult admission; cooperative purchases and workshops are separate and not priced here.',
      jordanian: .25,
      international: 1,
    ),
    PriceEstimate(
      id: 'jerash',
      label: 'Jerash Archaeological City',
      unit: 'per person',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board entrance-fee schedule',
      sourceUrl: tourismFeesUrl,
      checkedAt: checkedAt,
      conditions:
          'Includes archaeological museum; Jordan Pass includes eligible entry subject to its terms.',
      jordanian: .5,
      international: 10,
    ),
    PriceEstimate(
      id: 'ajloun-castle',
      label: 'Ajloun Castle',
      unit: 'per person',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board entrance-fee schedule',
      sourceUrl: tourismFeesUrl,
      checkedAt: checkedAt,
      conditions: 'Includes Ajloun Museum.',
      jordanian: .25,
      international: 3,
    ),
    PriceEstimate(
      id: 'ajloun-mar-elias',
      label: 'Mar Elias',
      unit: 'per person',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board entrance-fee schedule',
      sourceUrl: tourismFeesUrl,
      checkedAt: checkedAt,
      conditions: 'Adult listed rate.',
      jordanian: .25,
      international: 3,
    ),
    PriceEstimate(
      id: 'umm-qais',
      label: 'Umm Qais archaeological city',
      unit: 'per person',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board entrance-fee schedule',
      sourceUrl: tourismFeesUrl,
      checkedAt: checkedAt,
      conditions: 'Includes museum.',
      jordanian: .25,
      international: 5,
    ),
    PriceEstimate(
      id: 'pella',
      label: 'Pella (Tabaqat Fahl)',
      unit: 'per person',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board entrance-fee schedule',
      sourceUrl: tourismFeesUrl,
      checkedAt: checkedAt,
      conditions: 'Adult listed rate.',
      jordanian: .25,
      international: 2,
    ),
    PriceEstimate(
      id: 'dar-saraya',
      label: 'Saraya Museum, Irbid',
      unit: 'per person',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board entrance-fee schedule',
      sourceUrl: tourismFeesUrl,
      checkedAt: checkedAt,
      conditions: 'Official listing says Saraya Museum/Irbid.',
      jordanian: .25,
      international: 2,
    ),
    PriceEstimate(
      id: 'madaba-archaeological',
      label: 'Madaba Archaeological Park and Museum',
      unit: 'per person',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board entrance-fee schedule',
      sourceUrl: tourismFeesUrl,
      checkedAt: checkedAt,
      conditions: 'Adult listed rate; covers the park and museum entry.',
      jordanian: .25,
      international: 3,
    ),
    PriceEstimate(
      id: 'mount-nebo',
      label: 'Mount Nebo',
      unit: 'per person',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board entrance-fee schedule',
      sourceUrl: tourismFeesUrl,
      checkedAt: checkedAt,
      conditions: 'Adult listed rate.',
      jordanian: .5,
      international: 2,
    ),
    PriceEstimate(
      id: 'umm-al-jimal',
      label: 'Umm Al Jimal and listed Mafraq sites',
      unit: 'per person',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board entrance-fee schedule',
      sourceUrl: tourismFeesUrl,
      checkedAt: checkedAt,
      conditions:
          'Fee table groups Umm Al Jimal with several Mafraq sites; confirm site-specific operations.',
      jordanian: .25,
      international: 2,
    ),
    PriceEstimate(
      id: 'shobak',
      label: 'Shobak Castle',
      unit: 'per person',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board entrance-fee schedule',
      sourceUrl: tourismFeesUrl,
      checkedAt: checkedAt,
      conditions: 'Adult listed rate.',
      jordanian: .25,
      international: 1,
    ),
    PriceEstimate(
      id: 'karak',
      label: 'Karak Castle',
      unit: 'per person',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board entrance-fee schedule',
      sourceUrl: tourismFeesUrl,
      checkedAt: checkedAt,
      conditions: 'Includes Archaeological Museum.',
      jordanian: .25,
      international: 2,
    ),
    PriceEstimate(
      id: 'desert-castles',
      label: 'Qasr Amra, Qasr Kharana and listed Desert Castles',
      unit: 'per person',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board entrance-fee schedule',
      sourceUrl: tourismFeesUrl,
      checkedAt: checkedAt,
      conditions:
          'Grouped rate in the official schedule for the listed desert castles.',
      jordanian: .25,
      international: 3,
    ),
    PriceEstimate(
      id: 'aqaba-castle',
      label: 'Aqaba Castle',
      unit: 'per person',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board entrance-fee schedule',
      sourceUrl: tourismFeesUrl,
      checkedAt: checkedAt,
      conditions:
          'The schedule groups Aqaba Castle with Hamima and Sharif Hussein bin Ali Mosque.',
      jordanian: .25,
      international: 3,
    ),
    PriceEstimate(
      id: 'petra',
      label: 'Petra daytime entry',
      unit: 'per person per visit',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Petra Development and Tourism Region Authority fee schedule',
      sourceUrl: petraFeesUrl,
      checkedAt: checkedAt,
      conditions:
          'Jordanian JOD 1; qualifying resident JOD 10; international visitor staying in Jordan JOD 50 for 1 day; same-day visitor JOD 90. Choose the day-visitor ticket class when applicable. Jordan Pass eligibility/coverage and Petra by Night are separate conditions.',
      jordanian: 1,
      resident: 10,
      international: 50,
      dayVisitor: 90,
    ),
    PriceEstimate(
      id: 'wadi-rum-entry',
      label: 'Wadi Rum Protected Area entry',
      unit: 'per person',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board entrance-fee schedule',
      sourceUrl: tourismFeesUrl,
      checkedAt: checkedAt,
      conditions:
          'Jordanian JOD 1; foreign visitor JOD 5. Jordan Pass may cover eligible entry; verify at the visitor center.',
      jordanian: 1,
      international: 5,
    ),
    PriceEstimate(
      id: 'wadi-rum-jeep',
      label: 'Wadi Rum 4-hour jeep tour',
      unit: 'per person',
      confidence: PriceConfidence.publishedMarket,
      sourceName: 'Published Wadi Rum operator rate card',
      sourceUrl: wadiRumOperatorUrl,
      checkedAt: checkedAt,
      conditions:
          'Operator lists JOD 40/person for groups of 2–4 and JOD 35/person for 5–8; guide, hike, water, tea and return to village included. Market price, not government-fixed.',
      low: 35,
      high: 40,
    ),
    PriceEstimate(
      id: 'dana-trails-short',
      label: 'Dana short guided trails (up to 2 hours)',
      unit: 'per person per trail',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'RSCN Tourism Trails Price List 2026',
      sourceUrl: rscn2026Url,
      checkedAt: checkedAt,
      conditions:
          'Dana Village, Rummana Mountain, Rummana Campsite and Caves trails; minimum 6, maximum 20; includes reserve entry and guide. Transport to trail start is extra.',
      jordanian: 6,
      resident: 8,
      international: 10,
    ),
    PriceEstimate(
      id: 'dana-trails-medium',
      label: 'Dana medium trails (2–4 hours)',
      unit: 'per person per trail',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'RSCN Tourism Trails Price List 2026',
      sourceUrl: rscn2026Url,
      checkedAt: checkedAt,
      conditions:
          'Shaq El Reesh, Nawatef and White Dome; minimum 6, maximum 20; includes reserve entry and guide. Transport is extra.',
      jordanian: 7,
      resident: 10,
      international: 12,
    ),
    PriceEstimate(
      id: 'dana-trails-long',
      label: 'Dana long trails (6–9 hours)',
      unit: 'per person per trail',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'RSCN Tourism Trails Price List 2026',
      sourceUrl: rscn2026Url,
      checkedAt: checkedAt,
      conditions:
          'Wadi Dana, Wadi Ghweir and Wadi Al Dathneh; minimum 10, maximum 20; includes entry and guide. Transport to start/return is extra.',
      jordanian: 14,
      resident: 17,
      international: 20,
    ),
    PriceEstimate(
      id: 'mujib-siq',
      label: 'Mujib Siq water trail',
      unit: 'per person per activity',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'RSCN Mujib Biosphere Reserve Trails 2026',
      sourceUrl:
          'https://www.rscn.org.jo/uploaded_files/reservation/Mujib%20Biosphere%20Reserve%20Trails%202026.pdf',
      checkedAt: checkedAt,
      conditions:
          'Self-guided, 2–3 hours, seasonal/weather dependent; official 2026 rate card says tax inclusive.',
      jordanian: 17,
      resident: 21,
      international: 23,
    ),
    PriceEstimate(
      id: 'airport-shuttle',
      label: 'QAIA–Amman airport express shuttle',
      unit: 'per person per one-way ride',
      confidence: PriceConfidence.officialFixed,
      sourceName: 'Jordan Tourism Board airport information',
      sourceUrl: airportUrl,
      checkedAt: checkedAt,
      conditions:
          'JOD 3 one-way between Queen Alia International Airport and Amman southern terminal; schedule varies by time.',
      low: 3,
      high: 3,
    ),
    PriceEstimate(
      id: 'amman-local-bus',
      label: 'Local public transport in Amman',
      unit: 'per person per one-way ride',
      confidence: PriceConfidence.marketEstimate,
      sourceName: 'Numbeo Amman contributor-reported transport range',
      sourceUrl: numbeoAmmanUrl,
      checkedAt: checkedAt,
      conditions:
          'Amman only; contributor-reported range, not an official fare or intercity rate.',
      low: .50,
      high: .60,
    ),
    PriceEstimate(
      id: 'amman-taxi',
      label: 'Amman taxi metered travel',
      unit: 'per ride plus distance',
      confidence: PriceConfidence.marketEstimate,
      sourceName: 'Numbeo Amman contributor-reported transport range',
      sourceUrl: numbeoAmmanUrl,
      checkedAt: checkedAt,
      conditions:
          'Amman standard tariff: start JOD 0.37–1.00 and approximately JOD 0.40–1.50 per km after converting the listed per-mile range; traffic, tolls and app fares vary.',
      low: .37,
      high: 1.00,
    ),
    PriceEstimate(
      id: 'food-inexpensive',
      label: 'Inexpensive restaurant meal in Amman',
      unit: 'per person per meal',
      confidence: PriceConfidence.marketEstimate,
      sourceName: 'Numbeo Amman contributor-reported restaurant range',
      sourceUrl: numbeoAmmanUrl,
      checkedAt: checkedAt,
      conditions:
          'Amman range, JOD 3–9; market estimate for an inexpensive restaurant meal, not a fixed street-food price or a named restaurant.',
      low: 3,
      high: 9,
    ),
    PriceEstimate(
      id: 'food-midrange',
      label: 'Mid-range restaurant meal for two in Amman',
      unit: 'per two-person meal',
      confidence: PriceConfidence.marketEstimate,
      sourceName: 'Numbeo Amman contributor-reported restaurant range',
      sourceUrl: numbeoAmmanUrl,
      checkedAt: checkedAt,
      conditions:
          'Three courses without drinks; contributor-reported Amman range JOD 30–65.',
      low: 30,
      high: 65,
    ),
  ];

  static final Map<String, PriceEstimate> _byId = {
    for (final estimate in _officialFees) estimate.id: estimate,
  };

  static final Map<String, PriceEstimate> _byPlace = {
    'amman-roman-theatre': _byId['roman-theatre']!,
    'amman-citadel': _byId['amman-citadel']!,
    'amman-iraq-al-amir': _byId['amman-iraq-al-amir']!,
    'jerash-roman-city': _byId['jerash']!,
    'ajloun-castle': _byId['ajloun-castle']!,
    'ajloun-mar-elias': _byId['ajloun-mar-elias']!,
    'irbid-umm-qais': _byId['umm-qais']!,
    'irbid-pella': _byId['pella']!,
    'irbid-dar-saraya': _byId['dar-saraya']!,
    'madaba-mosaic-map': _byId['madaba-archaeological']!,
    'madaba-mount-nebo': _byId['mount-nebo']!,
    'mafraq-umm-al-jimal': _byId['umm-al-jimal']!,
    'maan-shobak-castle': _byId['shobak']!,
    'zarqa-qasr-amra': _byId['desert-castles']!,
    'zarqa-qasr-kharana': _byId['desert-castles']!,
    'zarqa-qasr-azraq': _byId['desert-castles']!,
    'aqaba-fort': _byId['aqaba-castle']!,
    'maan-petra': _byId['petra']!,
    'maan-wadi-rum': _byId['wadi-rum-jeep']!,
    'tafilah-dana': _byId['dana-trails-short']!,
    'amman-al-balad-markets': _byId['food-inexpensive']!,
    'amman-jabal-luweibdeh': _byId['food-inexpensive']!,
  };

  /// Prefer published Supabase admission/reserve fees for the selected
  /// destination. Vehicle-only fees cannot be treated as per-person admission.
  /// Local source-based references remain as an offline fallback.
  static PriceEstimate forPlaceId(String id) {
    final fact = PlaceVisitFactsRepository.forId(id);
    if (fact != null && fact.admissionKind != null &&
        fact.admissionKind != 'vehicle_entry' &&
        fact.admissionSourceUrl != null &&
        fact.admissionSourceUrl!.isNotEmpty &&
        (fact.admissionJordanian != null ||
         fact.admissionResident != null ||
         fact.admissionInternational != null ||
         fact.admissionDayVisitor != null)) {
      return PriceEstimate(
        id: id,
        label: fact.admissionNameEn ?? 'Published admission reference',
        unit: fact.admissionUnitEn ?? 'per person',
        confidence: PriceConfidence.officialFixed,
        sourceName: fact.admissionSourceName ?? 'Published source',
        sourceUrl: fact.admissionSourceUrl!,
        checkedAt: fact.admissionCheckedOn ?? '',
        conditions: fact.admissionConditionsEn ??
            'Check current admission conditions before traveling.',
        jordanian: fact.admissionJordanian,
        resident: fact.admissionResident,
        international: fact.admissionInternational,
        dayVisitor: fact.admissionDayVisitor,
      );
    }
    if (fact?.admissionKind == 'vehicle_entry') {
      // Do not invent a per-person cost from a vehicle admission reference.
      return _unverified(id);
    }
    return _byPlace[id] ?? _unverified(id);
  }

  static PriceEstimate get inexpensiveAmmanMeal =>
      _officialFees.firstWhere((estimate) => estimate.id == 'food-inexpensive');

  static PriceEstimate _unverified(String id) {
    var name = id;
    for (final place in JordanPlaceSeed.places) {
      if (place.id == id) {
        name = place.name;
        break;
      }
    }
    return PriceEstimate(
      id: 'unknown-$id',
      label: name,
      unit: 'price not verified',
      confidence: PriceConfidence.notVerified,
      sourceName: 'No reliable price source found',
      sourceUrl: '',
      checkedAt: checkedAt,
      conditions: 'Confirm admission or provider rates before booking.',
    );
  }

  static List<PriceEstimate> get referenceCosts => [
    _officialFees[17],
    _officialFees[19],
    _officialFees[20],
    _officialFees[21],
    _officialFees[22],
    _officialFees[23],
    _officialFees[24],
  ];

  static double? unitCost(PriceEstimate estimate, VisitorRateClass type) =>
      estimate.forVisitor(type);
}
