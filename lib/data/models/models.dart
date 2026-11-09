/// Minimal destination model for the first two TouRathi screens.
/// Replace the sample data with the supplied dataset after it is reviewed.
class Place {
  const Place({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.location,
    required this.locationAr,
    required this.rating,
    this.imageUrl = '',
    this.distance,
    this.price,
    this.category = 'heritage',
    this.isFavorite = false,
    this.historicalStory,
    this.historicalStoryAr,
    this.visitingHours,
    this.entryFee,
    this.reviewCount = 0,
    this.discoveryTier = 'unknown',
  });

  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final String location;
  final String locationAr;
  /// Demo value, not a live visitor rating.
  final double rating;
  final String imageUrl;
  final String? distance;
  final String? price;
  final String category;
  final bool isFavorite;
  final String? historicalStory;
  final String? historicalStoryAr;
  final String? visitingHours;
  final String? entryFee;
  final int reviewCount;
  final String discoveryTier;
}
