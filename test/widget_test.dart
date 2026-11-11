import 'package:flutter_test/flutter_test.dart';
import 'package:tourathi/core/supabase_config.dart';
import 'package:tourathi/data/mock/jordan_place_seed.dart';
import 'package:tourathi/data/content/destination_guides.dart';
import 'package:tourathi/data/media/place_photo_credits.dart';
import 'package:tourathi/data/repositories/place_repository.dart';

void main() {
  test('Supabase client uses a publishable key', () {
    expect(Uri.parse(SupabaseConfig.url).scheme, 'https');
    expect(SupabaseConfig.publishableKey.startsWith('sb_publishable_'), isTrue);
  });

  test('The bundled Jordan catalog contains 61 unique destinations', () {
    final all = JordanPlaceSeed.offlinePlaces;
    expect(all.length, 61);
    expect(all.map((p) => p.id).toSet().length, 61);
    expect(all.map((p) => p.category).toSet().length, 6);
    expect(all.every((p) => p.imageUrl.endsWith('${p.id}.jpg')), isTrue);
  });

  test('Each destination has a distinct guide and a credited image', () {
    final list = JordanPlaceSeed.offlinePlaces;
    expect(DestinationGuides.count, 61);
    expect(PlacePhotoCredits.count, 61);
    for (final place in list) {
      final guide = DestinationGuides.forId(place.id);
      final credit = PlacePhotoCredits.forId(place.id);
      expect(guide, isNotNull, reason: place.id);
      expect(credit, isNotNull, reason: place.id);
      expect(place.description, guide!.en);
      expect(place.descriptionAr, guide.ar);
      expect(credit!.sourceUrl.startsWith('https://'), isTrue);
      expect(credit.licenseUrl.startsWith('https://'), isTrue);
    }
    expect(PlacePhotoCredits.forId('irbid-wadi-ziglab')!.isRepresentative, isTrue);
  });

  test('A Supabase row maps to the Flutter place model', () {
    final record = PlaceRepository.fromRecord({
      'id': 'maan-petra',
      'name_en': 'Petra',
      'name_ar': 'البتراء',
      'governorate': 'Ma’an',
      'category': 'heritage',
      'discovery_context': 'famous',
      'description_en': 'Visit details require verification.',
      'description_ar': 'يجب التحقق من تفاصيل الزيارة.',
      'image_asset': 'assets/images/places/maan-petra.jpg',
    });
    expect(record.id, 'maan-petra');
    expect(record.discoveryTier, 'famous');
    expect(record.imageUrl, 'assets/images/places/maan-petra.jpg');
  });
}
