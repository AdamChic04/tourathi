import 'dart:convert';

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.visibility,
    required this.createdAt,
    required this.updatedAt,
    this.placeId,
    this.placeName,
    this.tripId,
    this.tripName,
    this.photoBase64,
    this.photoPath,
    this.pendingSync = false,
  });

  final String id, userId, title, body, visibility;
  final DateTime createdAt, updatedAt;
  final String? placeId, placeName, tripId, tripName, photoBase64, photoPath;
  final bool pendingSync;
  bool get isShared => visibility == 'shared';

  JournalEntry copyWith({bool? pendingSync}) => JournalEntry(
    id: id,
    userId: userId,
    title: title,
    body: body,
    visibility: visibility,
    createdAt: createdAt,
    updatedAt: updatedAt,
    placeId: placeId,
    placeName: placeName,
    tripId: tripId,
    tripName: tripName,
    photoBase64: photoBase64,
    photoPath: photoPath,
    pendingSync: pendingSync ?? this.pendingSync,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'body': body,
    'visibility': visibility,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'place_id': placeId,
    'place_name': placeName,
    'trip_id': tripId,
    'trip_name': tripName,
    'photo_base64': photoBase64,
    'photo_path': photoPath,
    'pending_sync': pendingSync,
  };

  factory JournalEntry.fromJson(Map<String, dynamic> j) => JournalEntry(
    id: j['id'] as String? ?? '',
    userId: j['user_id'] as String? ?? '',
    title: j['title'] as String? ?? '',
    body: j['body'] as String? ?? '',
    visibility: j['visibility'] as String? ?? 'private',
    createdAt:
        DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(j['updated_at'] as String? ?? '') ?? DateTime.now(),
    placeId: j['place_id'] as String?,
    placeName: j['place_name'] as String?,
    tripId: j['trip_id'] as String?,
    tripName: j['trip_name'] as String?,
    photoBase64: j['photo_base64'] as String?,
    photoPath: j['photo_path'] as String?,
    pendingSync: j['pending_sync'] as bool? ?? false,
  );

  factory JournalEntry.fromLocal(Map<String, dynamic> j) =>
      JournalEntry.fromJson(j);
  List<int>? get photoBytes =>
      photoBase64 == null ? null : base64Decode(photoBase64!);
}
