import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary — Desert Elegance
  static const Color sandBeige = Color(0xFFD9C2A3);
  static const Color desertGold = Color(0xFFC89B3C);
  static const Color warmBrown = Color(0xFF7A5C3E);
  static const Color darkCharcoal = Color(0xFF1E1E1E);
  static const Color ivoryWhite = Color(0xFFF8F4EE);

  // Accents
  static const Color emerald = Color(0xFF2E8B6E);
  static const Color softRed = Color(0xFFD45D5D);
  static const Color royalBlue = Color(0xFF3B6FD4);

  // Gradients
  static const LinearGradient desertGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD9C2A3), Color(0xFFC89B3C), Color(0xFF7A5C3E)],
  );

  static const LinearGradient goldShimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8D5A8), Color(0xFFC89B3C), Color(0xFFA67C2E)],
  );

  static const LinearGradient aiGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B6FD4), Color(0xFFC89B3C), Color(0xFF7A5C3E)],
  );

  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E1E1E), Color(0xFF2D2520), Color(0xFF1E1E1E)],
  );

  // Dark mode surfaces
  static const Color darkSurface = Color(0xFF2A2420);
  static const Color darkCard = Color(0xFF352E28);
  static const Color darkBorder = Color(0xFF4A4038);
}
