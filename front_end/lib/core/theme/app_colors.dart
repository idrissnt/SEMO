import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6200EE);
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color primaryColor = Color(0xFF00BFA6);  // Added for backwards compatibility
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);

  // Background and Surface
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;

  // Text Colors
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Colors.black;
  static const Color onSurface = Colors.black87;

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);

  // Gradient Colors
  static const LinearGradient storeCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Colors.black54,
    ],
  );

  // Additional Colors from old theme.dart
  static const Color primaryOld = Color(0xFF00BFA6);
  static const Color secondaryOld = Color(0xFF6C63FF);
  static const Color info = Color(0xFF2196F3);
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textDisabled = Colors.black38;
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE0E0E0);
  static const Color neutral300 = Color(0xFFBDBDBD);
  static const Color neutral400 = Color(0xFF9E9E9E);
  static const Color neutral500 = Color(0xFF757575);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00BFA6), Color(0xFF00D4A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Semantic Colors
  static const Color green = Color(0xFF4CAF50);
  static const Color red = Color(0xFFE53935);
}
