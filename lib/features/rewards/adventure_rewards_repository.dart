import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'adventure_rewards_models.dart';
import 'reward_catalog.dart';

abstract interface class AdventureRewardsRepository {
  Future<AdventureRewardsSnapshot> load();

  /// Persists the journal and points event as one local record update.
  Future<JournalAwardResult> saveCompletedTripJournal(TravelJournalEntry entry);

  /// Uses a stable transaction ID so retrying the same request cannot deduct twice.
  Future<RedemptionResult> redeem({
    required String transactionId,
    required RewardCatalogItem reward,
  });
}

/// Local-first implementation. Replace this adapter with an authenticated API
/// implementation without changing the Rewards or Journal screens.
class LocalAdventureRewardsRepository implements AdventureRewardsRepository {
  LocalAdventureRewardsRepository({SharedPreferences? preferences})
    : _preferences = preferences;

  static final LocalAdventureRewardsRepository instance =
      LocalAdventureRewardsRepository();

  static const _storagePrefix = 'adventure_rewards_v1';
  SharedPreferences? _preferences;
  Map<String, dynamic>? _data;
  String? _storageKey;
  String? _loadedUserId;
  Future<void> _queue = Future<void>.value();

  Future<T> _serialized<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _queue = _queue.then((_) async {
      try {
        completer.complete(await action());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  Future<void> _ensureLoaded() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Sign in to use Adventure Rewards.');
    }
    if (_loadedUserId != userId) {
      _loadedUserId = userId;
      _storageKey = '${_storagePrefix}_$userId';
      _data = null;
    }
    if (_data != null) return;
    _preferences ??= await SharedPreferences.getInstance();
    final stored = _preferences!.getString(_storageKey!);
    if (stored != null) {
      _data = jsonDecode(stored) as Map<String, dynamic>;
      return;
    }

    _data = {
      'userId': userId,
      'memberId': _newId(),
      'transactions': <dynamic>[],
      'redemptions': <dynamic>[],
      'journalEntries': <dynamic>[],
      'earnedTripIds': <String>[],
    };
    await _write(_data!);
  }

  Future<void> _write(Map<String, dynamic> value) async {
    final success = await _preferences!.setString(
      _storageKey!,
      jsonEncode(value),
    );
    if (!success) throw StateError('Could not save Adventure Rewards data.');
    _data = value;
  }

  @override
  Future<AdventureRewardsSnapshot> load() => _serialized(() async {
    await _ensureLoaded();
    return _snapshot(_data!);
  });

  @override
  Future<JournalAwardResult> saveCompletedTripJournal(
    TravelJournalEntry entry,
  ) => _serialized(() async {
    await _ensureLoaded();
    if (entry.tripId.trim().isEmpty ||
        entry.tripName.trim().isEmpty ||
        entry.destination.trim().isEmpty ||
        entry.reflection.trim().isEmpty) {
      throw ArgumentError('Complete every journal field before saving.');
    }

    final current = _data!;
    final earnedIds = List<String>.from(
      (current['earnedTripIds'] as List<dynamic>).cast<String>(),
    );
    if (earnedIds.contains(entry.tripId)) {
      return const JournalAwardResult(JournalAwardStatus.alreadyEarned, 0);
    }

    final next = _copy(current);
    earnedIds.add(entry.tripId);
    next['earnedTripIds'] = earnedIds;
    (next['journalEntries'] as List<dynamic>).add(entry.toJson());
    (next['transactions'] as List<dynamic>).add(
      PointsTransaction(
        id: 'trip-${entry.tripId}',
        title: entry.tripName.trim(),
        pointsDelta: AdventureRewardsConfig.pointsPerJournaledCompletedTrip,
        createdAt: DateTime.now(),
        tripId: entry.tripId,
      ).toJson(),
    );
    await _write(next);
    return const JournalAwardResult(
      JournalAwardStatus.earned,
      AdventureRewardsConfig.pointsPerJournaledCompletedTrip,
    );
  });

  @override
  Future<RedemptionResult> redeem({
    required String transactionId,
    required RewardCatalogItem reward,
  }) => _serialized(() async {
    await _ensureLoaded();
    final current = _data!;
    final existing =
        (current['redemptions'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .where((item) => item['transactionId'] == transactionId)
            .firstOrNull;
    final balance = _balance(current);
    if (existing != null) {
      return RedemptionResult(
        status: RedemptionStatus.alreadyProcessed,
        balance: balance,
        redemption: RewardRedemption.fromJson(existing),
      );
    }
    if (balance < reward.pointsCost) {
      return RedemptionResult(
        status: RedemptionStatus.insufficientPoints,
        balance: balance,
      );
    }

    final now = DateTime.now();
    final redemption = RewardRedemption(
      transactionId: transactionId,
      rewardId: reward.id,
      rewardTitle: reward.title,
      pointsCost: reward.pointsCost,
      referenceCode: 'TR-${_newId().substring(0, 10).toUpperCase()}',
      createdAt: now,
    );
    final next = _copy(current);
    (next['redemptions'] as List<dynamic>).add(redemption.toJson());
    (next['transactions'] as List<dynamic>).add(
      PointsTransaction(
        id: transactionId,
        title: reward.title,
        pointsDelta: -reward.pointsCost,
        createdAt: now,
        rewardId: reward.id,
      ).toJson(),
    );
    await _write(next);
    return RedemptionResult(
      status: RedemptionStatus.redeemed,
      balance: balance - reward.pointsCost,
      redemption: redemption,
    );
  });

  AdventureRewardsSnapshot _snapshot(Map<String, dynamic> data) {
    final transactions =
        (data['transactions'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(PointsTransaction.fromJson)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final redemptions =
        (data['redemptions'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(RewardRedemption.fromJson)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final entries =
        (data['journalEntries'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(
              (item) => TravelJournalEntry(
                id: item['id'] as String,
                tripId: item['tripId'] as String,
                tripName: item['tripName'] as String,
                destination: item['destination'] as String,
                reflection: item['reflection'] as String,
                completedAt: DateTime.parse(item['completedAt'] as String),
              ),
            )
            .toList()
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return AdventureRewardsSnapshot(
      memberId: data['memberId'] as String,
      pointsBalance: _balance(data),
      transactions: transactions,
      redemptions: redemptions,
      journalEntries: entries,
    );
  }

  int _balance(Map<String, dynamic> data) =>
      (data['transactions'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .fold<int>(0, (total, item) => total + (item['pointsDelta'] as int));

  Map<String, dynamic> _copy(Map<String, dynamic> value) =>
      jsonDecode(jsonEncode(value)) as Map<String, dynamic>;

  String _newId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
