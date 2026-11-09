import 'package:flutter/material.dart';

/// App-level presentation state. Favorites are session-only in this demo.
class AppProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;
  final Set<String> _favorites = {};

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  ThemeMode get themeMode => _themeMode;
  bool isFavorite(String placeId) => _favorites.contains(placeId);

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
