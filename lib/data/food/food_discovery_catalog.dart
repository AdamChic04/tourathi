import '../models/models.dart';

/// Food-themed discovery in TouRathi is a mix of markets, villages, farms and
/// cultural workshops. These are NOT verified restaurants or bookable meals.
enum FoodExperienceKind {
  markets,
  neighborhoods,
  villages,
  workshops,
  farms,
}

class JordanianDish {
  const JordanianDish({
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.symbol,
  });

  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final String symbol;
}

class FoodDiscoveryCatalog {
  FoodDiscoveryCatalog._();

  static const dishes = <JordanianDish>[
    JordanianDish(
      name: 'Mansaf',
      nameAr: 'المنسف',
      description: 'Rice, lamb and a jameed yogurt sauce',
      descriptionAr: 'أرز ولحم وصلصة اللبن الجميد',
      symbol: '🍚',
    ),
    JordanianDish(
      name: 'Maqluba',
      nameAr: 'المقلوبة',
      description: 'Layered rice with vegetables and often meat',
      descriptionAr: 'أرز بالخضار واللحم في طبقات مقلوبة',
      symbol: '🍲',
    ),
    JordanianDish(
      name: 'Falafel',
      nameAr: 'الفلافل',
      description: 'Crispy chickpea fritters',
      descriptionAr: 'أقراص حمص مقلية ومقرمشة',
      symbol: '🧆',
    ),
    JordanianDish(
      name: 'Knafeh',
      nameAr: 'الكنافة',
      description: 'Sweet cheese pastry with syrup',
      descriptionAr: 'حلوى الجبن مع القطر',
      symbol: '🍮',
    ),
    JordanianDish(
      name: 'Zarb',
      nameAr: 'الزرب',
      description: 'Bedouin-style slow cooking in an underground oven',
      descriptionAr: 'طبخ بدوي بطيء في فرن تحت الأرض',
      symbol: '🥘',
    ),
    JordanianDish(
      name: 'Galayet Bandora',
      nameAr: 'قلاية البندورة',
      description: 'Tomatoes cooked with olive oil and seasonings',
      descriptionAr: 'بندورة مطبوخة بزيت الزيتون والتوابل',
      symbol: '🍅',
    ),
  ];

  static FoodExperienceKind kindFor(String id) => switch (id) {
    'amman-al-balad-markets' => FoodExperienceKind.markets,
    'amman-jabal-luweibdeh' => FoodExperienceKind.neighborhoods,
    'jerash-sakib' || 'ajloun-rason' => FoodExperienceKind.villages,
    'balqa-iraq-al-amir' || 'madaba-mosaic-workshops' =>
      FoodExperienceKind.workshops,
    'maan-diseh' => FoodExperienceKind.farms,
    _ => FoodExperienceKind.neighborhoods,
  };

  static String kindLabel(FoodExperienceKind kind, bool ar) =>
      switch (kind) {
        FoodExperienceKind.markets => ar ? 'الأسواق' : 'Markets',
        FoodExperienceKind.neighborhoods => ar ? 'الأحياء' : 'Neighborhoods',
        FoodExperienceKind.villages => ar ? 'القرى' : 'Villages',
        FoodExperienceKind.workshops => ar ? 'الحرف والمجتمع' : 'Crafts & culture',
        FoodExperienceKind.farms => ar ? 'المزارع' : 'Farms',
      };

  static List<Place> experiences(Iterable<Place> places) =>
      places.where((place) => place.category == 'food').toList(growable: false);

  static List<String> governorates(Iterable<Place> places) {
    final regions = places
        .map((place) => place.location.split(' Governorate').first.trim())
        .toSet()
        .toList()
      ..sort();
    return regions;
  }

  static List<Place> filter({
    required Iterable<Place> places,
    String query = '',
    String? governorate,
    FoodExperienceKind? kind,
  }) {
    final needle = query.trim().toLowerCase();
    return experiences(places).where((place) {
      if (kind != null && kindFor(place.id) != kind) return false;
      if (governorate != null &&
          !place.location.startsWith('$governorate Governorate')) {
        return false;
      }
      if (needle.isEmpty) return true;
      return [
        place.name,
        place.nameAr,
        place.location,
        place.locationAr,
        place.description,
        place.descriptionAr,
      ].join(' ').toLowerCase().contains(needle);
    }).toList(growable: false);
  }
}
