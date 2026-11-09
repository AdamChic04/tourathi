import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static const double radiusSmall = 12;
  static const double radiusMedium = 20;
  static const double radiusLarge = 28;

  static ThemeData lightTheme({bool isArabic = false}) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.desertGold,
        primary: AppColors.desertGold,
        secondary: AppColors.warmBrown,
        surface: AppColors.ivoryWhite,
        onPrimary: Colors.white,
        onSurface: AppColors.darkCharcoal,
      ),
      scaffoldBackgroundColor: AppColors.ivoryWhite,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkCharcoal,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.textStyle(
          isArabic: isArabic,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkCharcoal,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.desertGold,
        unselectedItemColor: AppColors.warmBrown,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.sandBeige.withValues(alpha: 0.3),
        selectedColor: AppColors.desertGold,
        labelStyle: AppTypography.poppins(fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: AppColors.sandBeige.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.desertGold, width: 1.5),
        ),
        hintStyle: AppTypography.poppins(
          fontSize: 14,
          color: AppColors.warmBrown.withValues(alpha: 0.6),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.sandBeige.withValues(alpha: 0.4),
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.warmBrown),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.desertGold,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
    );
    return base.copyWith(
      textTheme: _textTheme(isArabic, Brightness.light),
    );
  }

  static ThemeData darkTheme({bool isArabic = false}) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.desertGold,
        brightness: Brightness.dark,
        primary: AppColors.desertGold,
        secondary: AppColors.sandBeige,
        surface: AppColors.darkSurface,
        onPrimary: AppColors.darkCharcoal,
        onSurface: AppColors.ivoryWhite,
      ),
      scaffoldBackgroundColor: AppColors.darkCharcoal,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ivoryWhite,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.textStyle(
          isArabic: isArabic,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.ivoryWhite,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.desertGold,
        unselectedItemColor: AppColors.sandBeige,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCard,
        selectedColor: AppColors.desertGold,
        labelStyle: AppTypography.poppins(fontSize: 13, color: AppColors.ivoryWhite),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.desertGold, width: 1.5),
        ),
        hintStyle: AppTypography.poppins(
          fontSize: 14,
          color: AppColors.sandBeige.withValues(alpha: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.sandBeige),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.desertGold,
        foregroundColor: AppColors.darkCharcoal,
        elevation: 8,
      ),
    );
    return base.copyWith(
      textTheme: _textTheme(isArabic, Brightness.dark),
    );
  }

  static TextTheme _textTheme(bool isArabic, Brightness brightness) {
    final color = brightness == Brightness.light
        ? AppColors.darkCharcoal
        : AppColors.ivoryWhite;
    return TextTheme(
      displayLarge: AppTypography.textStyle(
        isArabic: isArabic,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      displayMedium: AppTypography.textStyle(
        isArabic: isArabic,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      headlineLarge: AppTypography.textStyle(
        isArabic: isArabic,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineMedium: AppTypography.textStyle(
        isArabic: isArabic,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: AppTypography.textStyle(
        isArabic: isArabic,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: AppTypography.textStyle(
        isArabic: isArabic,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      bodyLarge: AppTypography.textStyle(
        isArabic: isArabic,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      bodyMedium: AppTypography.textStyle(
        isArabic: isArabic,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      bodySmall: AppTypography.textStyle(
        isArabic: isArabic,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: color.withValues(alpha: 0.7),
      ),
      labelLarge: AppTypography.textStyle(
        isArabic: isArabic,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
