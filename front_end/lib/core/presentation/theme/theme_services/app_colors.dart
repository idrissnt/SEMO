import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color semoWelcome = Color.fromARGB(255, 227, 225, 225);
  static Color primary = Colors.blue.shade800;
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color secondary = Colors.white;
  static const Color secondaryVariant = Color(0xFFF4F4F4);

  // Background and Surface
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color.fromARGB(255, 241, 240, 240);

  // Text Colors
  static const Color textPrimaryColor = Color.fromARGB(255, 8, 8, 8);
  static const Color textSecondaryColor = Colors.white;

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
