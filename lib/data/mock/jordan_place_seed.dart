import '../models/models.dart';

/// Curated discovery seed for the prototype. These records intentionally omit
/// unverified coordinates, opening hours, prices and accessibility claims.
/// Verify permission/access and current details with authoritative local sources
/// before using them to generate real itineraries.
class JordanPlaceSeed {
  JordanPlaceSeed._();

  static Place _place(String id, String en, String ar, String governorate,
      String category, String kind) => Place(
        id: id,
        name: en,
        nameAr: ar,
        description: '$kind discovery record. Visit details require verification.',
        descriptionAr: 'سجل استكشاف ($kind). يجب التحقق من تفاصيل الزيارة.',
        location: '$governorate Governorate, Jordan',
        locationAr: 'محافظة $governorate، الأردن',
        imageUrl: 'assets/images/places/$id.jpg',
        rating: 0,
        category: category,
        discoveryTier: kind.contains('famous') ? 'famous' : 'local_or_mixed',
      );

  static final List<Place> _offlinePlaces = [
    _place('amman-roman-theatre', 'Roman Theatre', 'المدرج الروماني', 'Amman', 'heritage', 'famous'),
    _place('amman-citadel', 'Amman Citadel', 'جبل القلعة', 'Amman', 'heritage', 'famous'),
    _place('amman-jordan-museum', 'The Jordan Museum', 'متحف الأردن', 'Amman', 'museums', 'famous'),
    _place('amman-darat-funun', 'Darat al Funun', 'دارة الفنون', 'Amman', 'museums', 'local culture'),
    _place('amman-al-balad-markets', 'Downtown Amman markets', 'أسواق وسط البلد', 'Amman', 'food', 'local experience'),
    _place('amman-jabal-luweibdeh', 'Jabal Al Lweibdeh arts district', 'حي جبل اللويبدة الفني', 'Amman', 'food', 'local culture'),
    _place('amman-iraq-al-amir', 'Iraq Al Amir', 'عراق الأمير', 'Amman', 'heritage', 'heritage and community experience'),
    _place('balqa-as-salt', 'Historic As-Salt', 'السلط التراثية', 'Balqa', 'heritage', 'famous'),
    _place('balqa-abu-jaber-museum', 'Abu Jaber House Museum', 'متحف بيت أبو جابر', 'Balqa', 'museums', 'heritage'),
    _place('balqa-wadi-shuaib', 'Wadi Shuaib', 'وادي شعيب', 'Balqa', 'hiking', 'nature'),
    _place('balqa-iraq-al-amir', 'Iraq Al Amir women cooperative', 'تعاونية نساء عراق الأمير', 'Balqa', 'food', 'community craft'),
    _place('zarqa-azraq-wetland', 'Azraq Wetland Reserve', 'محمية الأزرق المائية', 'Zarqa', 'hiking', 'famous nature'),
    _place('zarqa-shawmari', 'Shaumari Wildlife Reserve', 'محمية الشومري', 'Zarqa', 'hiking', 'nature'),
    _place('zarqa-qasr-amra', 'Qasr Amra', 'قصر عمرة', 'Zarqa', 'heritage', 'famous'),
    _place('zarqa-qasr-kharana', 'Qasr Kharana', 'قصر الخرّانة', 'Zarqa', 'heritage', 'desert heritage'),
    _place('zarqa-qasr-azraq', 'Azraq Castle', 'قلعة الأزرق', 'Zarqa', 'heritage', 'heritage'),
    _place('irbid-umm-qais', 'Umm Qais', 'أم قيس', 'Irbid', 'heritage', 'famous'),
    _place('irbid-pella', 'Pella (Tabaqat Fahl)', 'بيلا (طبقة فحل)', 'Irbid', 'heritage', 'archaeology'),
    _place('irbid-dar-saraya', 'Dar As-Saraya Museum', 'متحف دار السرايا', 'Irbid', 'museums', 'heritage'),
    _place('irbid-beit-arar', 'Beit Arar', 'بيت عرار', 'Irbid', 'museums', 'culture'),
    _place('irbid-yarmouk-reserve', 'Yarmouk Forest Reserve', 'محمية غابات اليرموك', 'Irbid', 'hiking', 'nature'),
    _place('irbid-wadi-ziglab', 'Wadi Ziglab', 'وادي زقلاب', 'Irbid', 'hiking', 'nature'),
    _place('jerash-roman-city', 'Jerash Archaeological City', 'مدينة جرش الأثرية', 'Jerash', 'heritage', 'famous'),
    _place('jerash-dibbeen', 'Dibbeen Forest Reserve', 'محمية غابات دبين', 'Jerash', 'hiking', 'nature'),
    _place('jerash-souf', 'Souf Forest Reserve', 'محمية غابات سوف', 'Jerash', 'hiking', 'nature'),
    _place('jerash-sakib', 'Sakib village', 'قرية ساكب', 'Jerash', 'food', 'local rural experience'),
    _place('ajloun-castle', 'Ajloun Castle', 'قلعة عجلون', 'Ajloun', 'heritage', 'famous'),
    _place('ajloun-forest-reserve', 'Ajloun Forest Reserve', 'محمية غابات عجلون', 'Ajloun', 'hiking', 'famous nature'),
    _place('ajloun-mar-elias', 'Mar Elias', 'مار إلياس', 'Ajloun', 'religious', 'heritage'),
    _place('ajloun-rajeb', 'Rajeb valley and seasonal falls', 'وادي راجب وشلالاته الموسمية', 'Ajloun', 'hiking', 'nature; seasonal conditions vary'),
    _place('ajloun-rason', 'Rasoun village', 'قرية رأسون', 'Ajloun', 'food', 'local rural experience'),
    _place('mafraq-umm-al-jimal', 'Umm Al Jimal', 'أم الجمال', 'Mafraq', 'heritage', 'famous'),
    _place('mafraq-rehab', 'Rehab archaeological churches', 'كنائس رحاب الأثرية', 'Mafraq', 'religious', 'archaeology'),
    _place('mafraq-umm-qutayn', 'Umm Qutayn', 'أم القطين', 'Mafraq', 'heritage', 'archaeology'),
    _place('mafraq-dayr-al-kahf', 'Dayr Al Kahf', 'دير الكهف', 'Mafraq', 'heritage', 'lesser-known archaeology; access verify'),
    _place('madaba-mosaic-map', 'Madaba Mosaic Map', 'خريطة مادبا الفسيفسائية', 'Madaba', 'religious', 'famous heritage'),
    _place('madaba-mount-nebo', 'Mount Nebo', 'جبل نيبو', 'Madaba', 'religious', 'famous'),
    _place('madaba-umm-ar-rasas', 'Umm ar-Rasas', 'أم الرصاص', 'Madaba', 'heritage', 'archaeology'),
    _place('madaba-mukawir', 'Mukawir (Machaerus)', 'مكاور', 'Madaba', 'heritage', 'archaeology'),
    _place('madaba-ma-in', 'Ma’in hot springs', 'حمامات ماعين', 'Madaba', 'adventure', 'nature; verify facility access'),
    _place('madaba-mosaic-workshops', 'Madaba mosaic workshops', 'مشاغل الفسيفساء في مادبا', 'Madaba', 'food', 'local craft; verify host availability'),
    _place('karak-castle', 'Karak Castle', 'قلعة الكرك', 'Karak', 'heritage', 'famous'),
    _place('karak-wadi-bin-hammad', 'Wadi Bin Hammad', 'وادي بن حماد', 'Karak', 'hiking', 'nature; conditions and access verify'),
    _place('karak-dhiban', 'Dhiban archaeological area', 'منطقة ذيبان الأثرية', 'Karak', 'heritage', 'archaeology'),
    _place('karak-ghor-safi', 'Ghor as-Safi and museum', 'غور الصافي ومتحفه', 'Karak', 'museums', 'culture and landscape'),
    _place('tafilah-dana', 'Dana Biosphere Reserve', 'محمية ضانا للمحيط الحيوي', 'Tafilah', 'hiking', 'famous nature'),
    _place('tafilah-afra', 'Afra hot springs', 'حمامات عفرا المعدنية', 'Tafilah', 'adventure', 'nature; check current operation'),
    _place('tafilah-busaira', 'Busaira archaeological sites', 'مواقع بصيرا الأثرية', 'Tafilah', 'heritage', 'archaeology'),
    _place('tafilah-wadi-hasa', 'Wadi Hasa', 'وادي الحسا', 'Tafilah', 'hiking', 'nature; route and conditions verify'),
    _place('tafilah-qadisiyah', 'Al Qadisiyah highlands', 'مرتفعات القادسية', 'Tafilah', 'hiking', 'nature'),
    _place('maan-petra', 'Petra', 'البتراء', 'Ma’an', 'heritage', 'famous'),
    _place('maan-little-petra', 'Little Petra (Siq al-Barid)', 'البتراء الصغيرة (السيق البارد)', 'Ma’an', 'heritage', 'archaeology'),
    _place('maan-shobak-castle', 'Shobak Castle', 'قلعة الشوبك', 'Ma’an', 'heritage', 'heritage'),
    _place('maan-jabal-haroun', 'Jabal Haroun', 'جبل هارون', 'Ma’an', 'religious', 'heritage; guided access recommended'),
    _place('maan-diseh', 'Disi village and farms', 'قرية ومزارع الديسة', 'Ma’an', 'food', 'local experience; host confirmation needed'),
    _place('maan-wadi-rum', 'Wadi Rum Protected Area', 'محمية وادي رم', 'Ma’an', 'adventure', 'famous nature; licensed operator required'),
    _place('aqaba-marine-reserve', 'Aqaba Marine Reserve', 'محمية العقبة البحرية', 'Aqaba', 'adventure', 'nature; follow marine rules'),
    _place('aqaba-fort', 'Aqaba Fort', 'قلعة العقبة', 'Aqaba', 'heritage', 'heritage'),
    _place('aqaba-bird-observatory', 'Aqaba Bird Observatory', 'مرصد طيور العقبة', 'Aqaba', 'hiking', 'nature; seasonal'),
    _place('aqaba-south-beaches', 'South Beach and reef areas', 'الشاطئ الجنوبي ومناطق الشعاب', 'Aqaba', 'adventure', 'nature; use designated access'),
    _place('aqaba-boat-trips', 'Red Sea boat and snorkeling experiences', 'رحلات القوارب والغطس في البحر الأحمر', 'Aqaba', 'adventure', 'local activity; verify licensed provider'),
  ];

  /// Bundled catalog is always available while offline or before sign-in.
  static List<Place> get offlinePlaces => _offlinePlaces;

  static List<Place>? _remotePlaces;
  static List<Place> get places => _remotePlaces ?? _offlinePlaces;

  /// Loaded from Supabase after successful authentication. Fallback remains
  /// available if the network or database is temporarily unreachable.
  static void setRemotePlaces(List<Place> records) {
    if (records.isNotEmpty) {
      _remotePlaces = List<Place>.unmodifiable(records);
    }
  }

  static List<String> get categories =>
      places.map((place) => place.category).toSet().toList();
}


