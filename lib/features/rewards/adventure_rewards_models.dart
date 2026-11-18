class RewardCatalogItem {
  const RewardCatalogItem({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.pointsCost,
    required this.category,
  });

  final String id;
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  final int pointsCost;
  final String category;
}

class TravelJournalEntry {
  const TravelJournalEntry({
    required this.id,
    required this.tripId,
    required this.tripName,
    required this.destination,
    required this.reflection,
    required this.completedAt,
  });

  final String id;

  /// Stable trip identifier supplied by the trip source when one exists.
  final String tripId;
  final String tripName;
  final String destination;
  final String reflection;
  final DateTime completedAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'tripId': tripId,
    'tripName': tripName,
    'destination': destination,
    'reflection': reflection,
    'completedAt': completedAt.toIso8601String(),
  };
}

class PointsTransaction {
  const PointsTransaction({
    required this.id,
    required this.title,
    required this.pointsDelta,
    required this.createdAt,
    this.tripId,
    this.rewardId,
  });

  final String id;
  final String title;
  final int pointsDelta;
  final DateTime createdAt;
  final String? tripId;
  final String? rewardId;

  factory PointsTransaction.fromJson(Map<String, dynamic> json) =>
      PointsTransaction(
        id: json['id'] as String,
        title: json['title'] as String,
        pointsDelta: json['pointsDelta'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        tripId: json['tripId'] as String?,
        rewardId: json['rewardId'] as String?,
      );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'pointsDelta': pointsDelta,
    'createdAt': createdAt.toIso8601String(),
    if (tripId != null) 'tripId': tripId,
    if (rewardId != null) 'rewardId': rewardId,
  };
}

class RewardRedemption {
  const RewardRedemption({
    required this.transactionId,
    required this.rewardId,
    required this.rewardTitle,
    required this.pointsCost,
    required this.referenceCode,
    required this.createdAt,
  });

  final String transactionId;
  final String rewardId;
  final String rewardTitle;
  final int pointsCost;
  final String referenceCode;
  final DateTime createdAt;

  factory RewardRedemption.fromJson(Map<String, dynamic> json) =>
      RewardRedemption(
        transactionId: json['transactionId'] as String,
        rewardId: json['rewardId'] as String,
        rewardTitle: json['rewardTitle'] as String,
        pointsCost: json['pointsCost'] as int,
        referenceCode: json['referenceCode'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, Object?> toJson() => {
    'transactionId': transactionId,
    'rewardId': rewardId,
    'rewardTitle': rewardTitle,
    'pointsCost': pointsCost,
    'referenceCode': referenceCode,
    'createdAt': createdAt.toIso8601String(),
  };
}

class AdventureRewardsSnapshot {
  const AdventureRewardsSnapshot({
    required this.memberId,
    required this.pointsBalance,
    required this.transactions,
    required this.redemptions,
    required this.journalEntries,
  });

  final String memberId;
  final int pointsBalance;
  final List<PointsTransaction> transactions;
  final List<RewardRedemption> redemptions;
  final List<TravelJournalEntry> journalEntries;
}

enum JournalAwardStatus { earned, alreadyEarned }

class JournalAwardResult {
  const JournalAwardResult(this.status, this.points);
  final JournalAwardStatus status;
  final int points;
}

enum RedemptionStatus { redeemed, insufficientPoints, alreadyProcessed }

class RedemptionResult {
  const RedemptionResult({
    required this.status,
    required this.balance,
    this.redemption,
  });

  final RedemptionStatus status;
  final int balance;
  final RewardRedemption? redemption;
}
