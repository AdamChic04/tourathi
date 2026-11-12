import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'tourathi.saved_ai_plans.v1';

class SavedPlanDay {
  const SavedPlanDay({required this.region, required this.placeIds});

  final String region;
  final List<String> placeIds;

  Map<String, Object?> toJson() => {'region': region, 'placeIds': placeIds};

  factory SavedPlanDay.fromJson(Map<String, dynamic> json) => SavedPlanDay(
    region: json['region'] as String? ?? 'Jordan',
    placeIds: (json['placeIds'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(growable: false),
  );
}

class SavedPlanRecord {
  const SavedPlanRecord({
    required this.id,
    required this.createdAt,
    required this.destination,
    required this.budget,
    required this.travelers,
    required this.daysCount,
    required this.interests,
    required this.pace,
    required this.discovery,
    required this.visitorClass,
    required this.estimatedLow,
    required this.estimatedHigh,
    required this.usedAi,
    required this.days,
    required this.priceSnapshots,
    this.travelDate = '',
    this.startLocation = 'Amman',
    this.mobilityNeeds = '',
    this.accessibilityNeeds = '',
    this.dietaryNeeds = '',
    this.explanation = '',
    this.placeReasons = const {},
    this.chatHistory = const [],
    this.otherCostsAllowance = 0,
    this.additionalRequests = '',
  });

  final String id;
  final DateTime createdAt;
  final String destination;
  final double budget;
  final int travelers;
  final int daysCount;
  final List<String> interests;
  final String pace;
  final String discovery;
  final String visitorClass;
  final double estimatedLow;
  final double estimatedHigh;
  final bool usedAi;
  final List<SavedPlanDay> days;
  final Map<String, Map<String, Object?>> priceSnapshots;
  final String travelDate;
  final String startLocation;
  final String mobilityNeeds;
  final String accessibilityNeeds;
  final String dietaryNeeds;
  final String explanation;
  final Map<String, String> placeReasons;
  final List<String> chatHistory;
  final double otherCostsAllowance;
  final String additionalRequests;

  Map<String, Object?> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'destination': destination,
    'budget': budget,
    'travelers': travelers,
    'daysCount': daysCount,
    'interests': interests,
    'pace': pace,
    'discovery': discovery,
    'visitorClass': visitorClass,
    'estimatedLow': estimatedLow,
    'estimatedHigh': estimatedHigh,
    'usedAi': usedAi,
    'days': days.map((day) => day.toJson()).toList(),
    'priceSnapshots': priceSnapshots,
    'travelDate': travelDate,
    'startLocation': startLocation,
    'mobilityNeeds': mobilityNeeds,
    'accessibilityNeeds': accessibilityNeeds,
    'dietaryNeeds': dietaryNeeds,
    'explanation': explanation,
    'placeReasons': placeReasons,
    'chatHistory': chatHistory,
    'otherCostsAllowance': otherCostsAllowance,
    'additionalRequests': additionalRequests,
  };

  factory SavedPlanRecord.fromJson(
    Map<String, dynamic> json,
  ) => SavedPlanRecord(
    id: json['id'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    destination: json['destination'] as String? ?? 'Jordan',
    budget: (json['budget'] as num?)?.toDouble() ?? 0,
    travelers: (json['travelers'] as num?)?.toInt() ?? 1,
    daysCount: (json['daysCount'] as num?)?.toInt() ?? 1,
    interests: (json['interests'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(growable: false),
    pace: json['pace'] as String? ?? 'balanced',
    discovery: json['discovery'] as String? ?? 'mixed',
    visitorClass: json['visitorClass'] as String? ?? 'international',
    estimatedLow: (json['estimatedLow'] as num?)?.toDouble() ?? 0,
    estimatedHigh: (json['estimatedHigh'] as num?)?.toDouble() ?? 0,
    usedAi: json['usedAi'] as bool? ?? false,
    days: (json['days'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(SavedPlanDay.fromJson)
        .toList(growable: false),
    priceSnapshots: (json['priceSnapshots'] as Map<String, dynamic>? ?? {}).map(
      (key, value) => MapEntry(
        key,
        value is Map<String, dynamic>
            ? Map<String, Object?>.from(value)
            : <String, Object?>{},
      ),
    ),
    travelDate: json['travelDate'] as String? ?? '',
    startLocation: json['startLocation'] as String? ?? 'Amman',
    mobilityNeeds: json['mobilityNeeds'] as String? ?? '',
    accessibilityNeeds: json['accessibilityNeeds'] as String? ?? '',
    dietaryNeeds: json['dietaryNeeds'] as String? ?? '',
    explanation: json['explanation'] as String? ?? '',
    placeReasons: (json['placeReasons'] as Map<String, dynamic>? ?? {}).map(
      (key, value) => MapEntry(key, value is String ? value : ''),
    ),
    chatHistory: (json['chatHistory'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(growable: false),
    otherCostsAllowance: (json['otherCostsAllowance'] as num?)?.toDouble() ?? 0,
    additionalRequests: json['additionalRequests'] as String? ?? '',
  );
}

class SavedPlansStore {
  SavedPlansStore._();
  static final instance = SavedPlansStore._();

  Future<List<SavedPlanRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(SavedPlanRecord.fromJson)
        .toList(growable: false);
  }

  Future<void> save(SavedPlanRecord record) async {
    final records = [...await load()];
    records.removeWhere((existing) => existing.id == record.id);
    records.insert(0, record);
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(
      _storageKey,
      jsonEncode(records.map((item) => item.toJson()).toList()),
    );
    if (!ok) {
      throw StateError('The itinerary could not be stored on this device.');
    }
  }

  Future<void> delete(String id) async {
    final records = [...await load()]..removeWhere((record) => record.id == id);
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(
      _storageKey,
      jsonEncode(records.map((item) => item.toJson()).toList()),
    );
    if (!ok) throw StateError('The saved itinerary could not be deleted.');
  }
}
