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
}
