import '../models/models.dart';

/// Temporary demo destinations. Not connected to Supabase.
class MockData {
  MockData._();

  static const List<Place> popularPlaces = [
    Place(
      id: 'petra',
      name: 'Petra',
      nameAr: 'البتراء',
      description: 'The rose-red archaeological city carved into sandstone cliffs.',
      descriptionAr: 'المدينة الأثرية الوردية المنحوتة في الجبال الرملية.',
      location: 'Ma\'an, Jordan',
      locationAr: 'معان، الأردن',
      rating: 4.9,
    ),
    Place(
      id: 'jerash',
      name: 'Jerash',
      nameAr: 'جرش',
      description: 'A historic city known for its Roman ruins and colonnaded streets.',
      descriptionAr: 'مدينة تاريخية تشتهر بآثارها الرومانية وشوارعها ذات الأعمدة.',
      location: 'Jerash, Jordan',
      locationAr: 'جرش، الأردن',
      rating: 4.8,
    ),
    Place(
      id: 'wadi-rum',
      name: 'Wadi Rum',
      nameAr: 'وادي رم',
      description: 'A dramatic desert landscape of sandstone mountains and dunes.',
      descriptionAr: 'صحراء خلابة من جبال الحجر الرملي والكثبان.',
      location: 'Aqaba, Jordan',
      locationAr: 'العقبة، الأردن',
      rating: 4.9,
    ),
    Place(
      id: 'dead-sea',
      name: 'Dead Sea',
      nameAr: 'البحر الميت',
      description: 'A remarkable salt lake famous for its extraordinary buoyancy.',
      descriptionAr: 'بحيرة مالحة فريدة تشتهر بقدرتها العالية على الطفو.',
      location: 'Dead Sea, Jordan',
      locationAr: 'البحر الميت، الأردن',
      rating: 4.7,
    ),
  ];
}
