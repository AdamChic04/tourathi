import 'adventure_rewards_models.dart';

/// One central configurable earn value; a backend can replace this policy.
class AdventureRewardsConfig {
  AdventureRewardsConfig._();

  static const int pointsPerJournaledCompletedTrip = 100;
}

/// Sample catalog records are structured separately for backend replacement.
class RewardCatalog {
  RewardCatalog._();

  static const List<RewardCatalogItem> items = [
    RewardCatalogItem(
      id: 'local-cafe-voucher',
      title: 'Local café voucher',
      titleAr: 'قسيمة مقهى محلي',
      description: 'A sample reward for a participating Jordanian café.',
      descriptionAr: 'مكافأة تجريبية لدى مقهى أردني مشارك.',
      pointsCost: 300,
      category: 'food',
    ),
    RewardCatalogItem(
      id: 'heritage-experience',
      title: 'Heritage experience credit',
      titleAr: 'رصيد تجربة تراثية',
      description: 'A sample credit toward a participating local experience.',
      descriptionAr: 'رصيد تجريبي لتجربة محلية مشاركة.',
      pointsCost: 600,
      category: 'experience',
    ),
    RewardCatalogItem(
      id: 'souvenir-credit',
      title: 'Jordanian artisan souvenir',
      titleAr: 'تذكار من الحرف الأردنية',
      description: 'A sample credit for a locally made souvenir.',
      descriptionAr: 'رصيد تجريبي لشراء تذكار مصنوع محلياً.',
      pointsCost: 900,
      category: 'craft',
    ),
  ];

  static RewardCatalogItem? byId(String id) {
    for (final reward in items) {
      if (reward.id == id) return reward;
    }
    return null;
  }
}
