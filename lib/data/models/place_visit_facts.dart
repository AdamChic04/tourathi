/// Source-attributed visitor facts read from Supabase.
/// Unavailable values stay null; 'checked' is not a real-time guarantee.
class PlaceVisitFacts {
  const PlaceVisitFacts({
    required this.placeId,
    this.gpsLat,
    this.gpsLon,
    this.gpsPrecision,
    this.gpsSourceUrl,
    this.gpsCheckedOn,
    this.hoursTextEn,
    this.hoursTextAr,
    this.hoursSourceUrl,
    this.hoursSourceName,
    this.hoursCheckedOn,
    this.admissionKind,
    this.admissionNameEn,
    this.admissionNameAr,
    this.admissionJordanian,
    this.admissionResident,
    this.admissionInternational,
    this.admissionDayVisitor,
    this.admissionUnitEn,
    this.admissionUnitAr,
    this.admissionConditionsEn,
    this.admissionConditionsAr,
    this.admissionSourceUrl,
    this.admissionSourceName,
    this.admissionCheckedOn,
  });

  final String placeId;
  final double? gpsLat;
  final double? gpsLon;
  final String? gpsPrecision;
  final String? gpsSourceUrl;
  final String? gpsCheckedOn;
  final String? hoursTextEn;
  final String? hoursTextAr;
  final String? hoursSourceUrl;
  final String? hoursSourceName;
  final String? hoursCheckedOn;
  final String? admissionKind;
  final String? admissionNameEn;
  final String? admissionNameAr;
  final double? admissionJordanian;
  final double? admissionResident;
  final double? admissionInternational;
  final double? admissionDayVisitor;
  final String? admissionUnitEn;
  final String? admissionUnitAr;
  final String? admissionConditionsEn;
  final String? admissionConditionsAr;
  final String? admissionSourceUrl;
  final String? admissionSourceName;
  final String? admissionCheckedOn;

  bool get hasSourcedCoordinates =>
      gpsLat != null && gpsLon != null &&
      gpsSourceUrl != null && gpsSourceUrl!.isNotEmpty;

  static double? _number(dynamic v) => v is num ? v.toDouble() : null;
  static String? _string(dynamic v) => v is String ? v : null;

  factory PlaceVisitFacts.fromJson(Map<String, dynamic> row) =>
      PlaceVisitFacts(
        placeId: row['place_id'] as String,
        gpsLat: _number(row['gps_lat']),
        gpsLon: _number(row['gps_lon']),
        gpsPrecision: _string(row['gps_precision']),
        gpsSourceUrl: _string(row['gps_source_url']),
        gpsCheckedOn: _string(row['gps_checked_on']),
        hoursTextEn: _string(row['hours_text_en']),
        hoursTextAr: _string(row['hours_text_ar']),
        hoursSourceUrl: _string(row['hours_source_url']),
        hoursSourceName: _string(row['hours_source_name']),
        hoursCheckedOn: _string(row['hours_checked_on']),
        admissionKind: _string(row['admission_kind']),
        admissionNameEn: _string(row['admission_name_en']),
        admissionNameAr: _string(row['admission_name_ar']),
        admissionJordanian: _number(row['admission_jordanian']),
        admissionResident: _number(row['admission_resident']),
        admissionInternational: _number(row['admission_international']),
        admissionDayVisitor: _number(row['admission_day_visitor']),
        admissionUnitEn: _string(row['admission_unit_en']),
        admissionUnitAr: _string(row['admission_unit_ar']),
        admissionConditionsEn: _string(row['admission_conditions_en']),
        admissionConditionsAr: _string(row['admission_conditions_ar']),
        admissionSourceUrl: _string(row['admission_source_url']),
        admissionSourceName: _string(row['admission_source_name']),
        admissionCheckedOn: _string(row['admission_checked_on']),
      );
}
