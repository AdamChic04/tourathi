import '../models/models.dart';
import '../models/place_visit_facts.dart';
import '../repositories/place_visit_facts_repository.dart';

/// Open real Google Maps searches without guessing coordinates.
///
/// For most destinations our catalog has a name and governorate, not a
/// verified visitor entrance. Named search avoids claiming a precise pin.
class PlaceMapLinks {
  PlaceMapLinks._();

  static String query(Place place, {PlaceVisitFacts? research}) {
    final facts = research ?? PlaceVisitFactsRepository.forId(place.id);
    if (facts?.hasSourcedCoordinates == true &&
        facts?.gpsPrecision == 'site_point') {
      return '${facts!.gpsLat},${facts.gpsLon}';
    }
    return '${place.name}, ${place.location}';
  }

  static Uri search(Place place, {PlaceVisitFacts? research}) =>
      Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': query(place, research: research),
      });

  static Uri directions(Place place, {PlaceVisitFacts? research}) =>
      Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': query(place, research: research),
      });
}
