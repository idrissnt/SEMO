import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';

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
class DefaultAssets {
  // Default asset values
  static const String defaultTitle = 'Tasker';

  // Conversion factor from degrees to radians
  static const double degToRad = 0.0174533;

  // Card appearance methods that return responsive values
  static double cardWidth(BuildContext context) =>
      context.getResponsiveWidthValue(165.0);

  static double cardHeight(BuildContext context) =>
      context.getResponsiveHeightValue(150.0);

  static double profileImageSize(BuildContext context) =>
      context.getResponsiveWidthValue(50.0);

  static double cardRadius(BuildContext context) =>
      context.getResponsiveWidthValue(20.0);

  // Card themes for left and right positions
  static const List<CardTheme> cardThemes = [
    // Left card theme
    CardTheme(
      angle: -5,
      mainCardColor: Colors.purple,
      stackCardColor: Colors.purple,
      position: CardPosition.left,
    ),
    // Right card theme
    CardTheme(
      angle: 5,
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
      blurRadius: isMainCard ? 8 : 5,
      offset: isMainCard ? const Offset(0, 3) : const Offset(0, 2),
    );
  }
}
