import 'package:flutter/material.dart';

import '../../data/mock/jordan_place_seed.dart';
import '../../data/repositories/place_repository.dart';
import '../../data/repositories/place_visit_facts_repository.dart';

/// App-level presentation state. Favorites are session-only in this demo.
class AppProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;
  final Set<String> _favorites = {};

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  ThemeMode get themeMode => _themeMode;
  bool isFavorite(String placeId) => _favorites.contains(placeId);

  bool _loadingPlaces = false;

  /// Reloads the catalog after login. Every screen and the planner reads the
  /// same current list; until this succeeds they show the bundled 61 places.
  Future<void> refreshPlaces() async {
    if (_loadingPlaces) return;
    _loadingPlaces = true;
    try {
      final places = await PlaceRepository.fetchPublished();
      if (places.isNotEmpty) {
        JordanPlaceSeed.setRemotePlaces(places);
        notifyListeners();
      }
    } catch (error) {
      debugPrint('Could not load places from Supabase; using offline list: $error');
    } finally {
      try {
        // Fact refresh fails independently of the base 61-place catalog.
        await PlaceVisitFactsRepository.refresh();
        notifyListeners();
      } catch (error) {
        debugPrint('Visitor facts unavailable; offline references remain: $error');
      }
      _loadingPlaces = false;
    }
  }

  void toggleFavorite(String placeId) {
    if (!_favorites.add(placeId)) _favorites.remove(placeId);
    notifyListeners();
  }

  void toggleLanguage() {
    _locale = isArabic ? const Locale('en') : const Locale('ar');
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
