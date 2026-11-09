import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;
  bool _onboardingComplete = false;
  final Set<String> _favoritePlaceIds = <String>{};

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get onboardingComplete => _onboardingComplete;

  /// Favorite places are shared across Home, Explore and Details in this
  /// session; persist them in Supabase after authentication is implemented.
  bool isFavorite(String placeId) => _favoritePlaceIds.contains(placeId);

  void toggleFavorite(String placeId) {
    if (!_favoritePlaceIds.add(placeId)) _favoritePlaceIds.remove(placeId);
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void toggleLanguage() {
    _locale = isArabic ? const Locale('en') : const Locale('ar');
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }

  void completeOnboarding() {
    _onboardingComplete = true;
    notifyListeners();
  }
}
