import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Position of a card in the layout
enum CardPosition { left, right }

/// Theme data for card styling
class CardTheme {
  final double angle;
  final MaterialColor mainCardColor;
  final MaterialColor stackCardColor;
  final CardPosition position;

  const CardTheme({
    required this.angle,
    required this.mainCardColor,
    required this.stackCardColor,
    required this.position,
  });

  // Get the appropriate shade of the color
  Color get mainColor => mainCardColor.shade100;
  Color get stackColor => stackCardColor.shade200;
}

/// Constants and utilities for asset handling
class DefaultTaskCardAssets {
  // Default profile text values
  static const String defaultTitle = 'Tasker';

  // Task card dimensions
  static double get taskCardSectionHeight => 270.h;

  // position for alls cards (left, right, background*2) to fit in the container
  static double get leftPosition => 18.r;
  static double get rightPosition => 5.r;
  static double get topPosition => 25.r;

  // task card background position
  static double get backgroundCardLeftPosition => -7.r;
  static double get backgroundCardTopPosition => -7.r;
  static double get backgroundCardAngleInclination => 5.r;

  // Conversion factor from degrees to radians
  static const double degToRad = 0.0174533;

  // card size
  static double get cardWidth => 165.w;
  static double get cardHeight => 180.h;
  static double get profileImageSize => 50.w;
  static double get cardRadius => 20.w;

  // Card themes for left and right positions
  static List<CardTheme> cardThemes = [
    // Left card theme
    CardTheme(
      angle: -5.r,
      mainCardColor: Colors.purple,
      stackCardColor: Colors.purple,
      position: CardPosition.left,
    ),
    // Right card theme
    CardTheme(
      angle: 5.r,
      mainCardColor: Colors.orange,
      stackCardColor: Colors.orange,
      position: CardPosition.right,
    ),
  ];

  /// Creates default card data when actual data is missing
  static Map<String, String> createCardData() {
    return {
      'mainImage': '',
      'profileImage': '',
      'profileTitle': defaultTitle,
    };
  }

  /// Creates a default background image when actual data is missing
  static String createBackgroundImage() {
    return '';
  }

  /// Get standard box shadow for main or background card
  static BoxShadow getBoxShadow({bool isMainCard = true}) {
    return BoxShadow(
      color: Colors.black,
      blurRadius: isMainCard ? 8.r : 5.r,
      offset: isMainCard ? Offset(0, 3.r) : Offset(0, 2.r),
    );
  }
}
