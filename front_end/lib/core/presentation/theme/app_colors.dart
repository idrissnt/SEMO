import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color semoWelcome = Color.fromARGB(255, 227, 225, 225);
  static Color primary = Colors.blue.shade700;
  static Color primaryVariant = Colors.blue.shade500;
  static const Color secondary = Colors.white;
  static const Color secondaryVariant = Color.fromARGB(255, 227, 227, 227);
  static const Color thirdColor = Color.fromARGB(255, 116, 116, 116);
  static const Color transparent = Colors.transparent;

  // Background and Surface
  static const Color background =
      Colors.white; // Using Color(0xFFFFFFFF) would also work
  static const Color surface = Color.fromARGB(255, 241, 240, 240);

  // Search Bar Colors
  static Color searchBarColor =
      Colors.grey[200] ?? const Color(0xFFEEEEEE); // Provide a fallback color
  static const Color searchBarHintColor = Color.fromARGB(255, 77, 77, 77);

  // Icon Colors
  static const Color iconColorFirstColor =
      Colors.black; // Using Color(0xFF000000) would also work
  static const Color iconColorSecondColor = Colors.grey;

  // Store Card Colors
  static const Color storeCardBorderColor = Color.fromARGB(255, 7, 59, 137);

  // Shadow Colors
  static const Color appBarShadowColor = Color.fromARGB(13, 13, 13, 13);
  static const Color storeCardShadowColor = Colors.black;

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
