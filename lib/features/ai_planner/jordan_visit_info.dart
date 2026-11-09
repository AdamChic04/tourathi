class PlaceVisitInfo {
  const PlaceVisitInfo({
    required this.placeId,
    required this.season,
    required this.hours,
    required this.sourceName,
    required this.sourceUrl,
    required this.checkedAt,
    required this.conditions,
  });

  final String placeId;
  final String season;
  final String hours;
  final String sourceName;
  final String sourceUrl;
  final String checkedAt;
  final String conditions;
}

/// Only records explicitly verified against a destination/operator source are
/// returned here. Other sites remain unknown and are never given invented hours.
class JordanVisitInfoCatalog {
  JordanVisitInfoCatalog._();

  static const checkedAt = '2026-11-07';
  static const _petraUrl = 'https://visitpetra.jo/en/Openinghours';

  static PlaceVisitInfo? forPlace(String placeId, {DateTime? visitDate}) {
    if (placeId != 'maan-petra') return null;
    final date = visitDate ?? DateTime.now();
    final summer =
        (date.month > 3 && date.month < 10) ||
        (date.month == 3 && date.day >= 2) ||
        (date.month == 10 && date.day == 1);
    return PlaceVisitInfo(
      placeId: placeId,
      season: summer ? 'Summer (Mar 2–Oct 1)' : 'Winter (Oct 2–Mar 1)',
      hours: summer ? '06:00–18:00' : '06:30–17:00',
      sourceName: 'Petra Development and Tourism Region Authority',
      sourceUrl: _petraUrl,
      checkedAt: checkedAt,
      conditions:
          'Site and visitor-center hours; ticket-office hours differ. Check current notices before travel.',
    );
  }
}
