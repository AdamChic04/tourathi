import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';

/// Loads the approved places catalog from TouRathi's Supabase PostgreSQL.
/// No service-role credentials, unverified coordinates, or made-up prices.
class PlaceRepository {
  PlaceRepository._();

  static Future<List<Place>> fetchPublished() async {
    final rows = await Supabase.instance.client
        .from('places')
        .select(
          'id,name_en,name_ar,governorate,category,discovery_context,'
          'description_en,description_ar,image_asset,sort_order',
        )
        .eq('is_published', true)
        .order('sort_order', ascending: true);

    return rows.map((row) => fromRecord(row)).toList(growable: false);
  }

  static Place fromRecord(Map<String, dynamic> row) {
    final governorate = row['governorate'] as String;
    final context = row['discovery_context'] as String? ?? '';
    return Place(
      id: row['id'] as String,
      name: row['name_en'] as String,
      nameAr: row['name_ar'] as String,
      description: row['description_en'] as String? ?? '',
      descriptionAr: row['description_ar'] as String? ?? '',
      location: '$governorate Governorate, Jordan',
      locationAr: 'محافظة $governorate، الأردن',
      // Images are bundled Flutter assets; don't depend on remote URLs.
      imageUrl: (row['image_asset'] as String?)?.isNotEmpty == true
          ? row['image_asset'] as String
          : "assets/images/places/${row['id']}.jpg",
      rating: 0, // No verified review data has been imported.
      category: row['category'] as String,
      discoveryTier:
          context.contains('famous') ? 'famous' : 'local_or_mixed',
    );
  }
}
