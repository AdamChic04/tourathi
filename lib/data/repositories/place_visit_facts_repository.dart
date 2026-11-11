import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/place_visit_facts.dart';

/// Read-only cached visitor research. Never exposes unsupported facts as zero.
class PlaceVisitFactsRepository {
  PlaceVisitFactsRepository._();

  static Map<String, PlaceVisitFacts> _cache = const {};
  static PlaceVisitFacts? forId(String id) => _cache[id];

  static Future<int> refresh() async {
    final rows = await Supabase.instance.client
        .from('place_visit_facts')
        .select(
          'place_id,gps_lat,gps_lon,gps_precision,gps_source_url,gps_checked_on,'
          'hours_text_en,hours_text_ar,hours_source_url,hours_source_name,hours_checked_on,'
          'admission_kind,admission_name_en,admission_name_ar,'
          'admission_jordanian,admission_resident,admission_international,'
          'admission_day_visitor,admission_unit_en,admission_unit_ar,'
          'admission_conditions_en,admission_conditions_ar,'
          'admission_source_url,admission_source_name,admission_checked_on',
        );
    final info = <String, PlaceVisitFacts>{};
    for (final row in rows) {
      final fact = PlaceVisitFacts.fromJson(row);
      info[fact.placeId] = fact;
    }
    _cache = Map.unmodifiable(info);
    return info.length;
  }
}
