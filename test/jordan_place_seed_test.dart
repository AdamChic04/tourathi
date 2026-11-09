import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tourathi/data/mock/jordan_place_seed.dart';

void main() {
  test('contains exactly 61 unique locations with attributed bundled images', () {
    final places = JordanPlaceSeed.places;
    expect(places, hasLength(61));
    expect(places.map((place) => place.id).toSet(), hasLength(61));
    for (final place in places) {
      expect(place.imageUrl, 'assets/images/places/${place.id}.jpg');
      expect(File(place.imageUrl).existsSync(), isTrue, reason: place.id);
      final attribution = File(
        'assets/images/places/${place.id}.source.json',
      );
      expect(attribution.existsSync(), isTrue, reason: place.id);
      final metadata = jsonDecode(attribution.readAsStringSync())
          as Map<String, dynamic>;
      expect(metadata['sourceUrl'], startsWith('https://commons.wikimedia.org/'),
          reason: place.id);
      expect(metadata['license'], matches(r'^(CC0|Public domain|CC BY|CC BY-SA|PDM)'),
          reason: place.id);
      expect(metadata['licenseUrl'], isNotEmpty, reason: place.id);
    }
    for (final governorate in [
      'Amman', 'Balqa', 'Zarqa', 'Irbid', 'Jerash', 'Ajloun',
      'Mafraq', 'Madaba', 'Karak', 'Tafilah', 'Ma’an', 'Aqaba',
    ]) {
      expect(places.any((place) => place.location.contains(governorate)), isTrue,
          reason: 'Missing $governorate');
    }
  });

  test('does not claim unverified prices, hours, ratings, or coordinates', () {
    for (final place in JordanPlaceSeed.places) {
      expect(place.rating, 0);
      expect(place.visitingHours, isNull);
      expect(place.entryFee, isNull);
      expect(place.distance, isNull);
      expect(place.price, isNull);
    }
  });
}
