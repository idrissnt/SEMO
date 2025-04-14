import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Colors.blueAccent;
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color secondary = Colors.black;
  static const Color secondaryVariant = Colors.black87;

  // Background and Surface
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color.fromARGB(255, 227, 225, 225);

  // Text Colors
  static const Color onPrimary = Color.fromARGB(255, 8, 8, 8);
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Colors.black87;
  static const Color onSurface = Colors.black38;
  static const Color lineColor = Color.fromARGB(255, 230, 228, 228);

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
}
