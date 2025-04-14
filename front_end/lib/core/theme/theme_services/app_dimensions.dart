import 'package:flutter/material.dart';

/// A fully responsive dimensions system for the app
/// All spacing, padding, and sizing will automatically adapt to different screen sizes

class AppDimensionsHeight {
  AppDimensionsHeight._();

  // Height breakpoints
  static const double _smallPhoneHeight = 640.0;
  static const double _phoneHeight = 800.0;

  // Responsive height scaling factors
  static double getHeightScaleFactor(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    if (height < _smallPhoneHeight) return 0.8;
    if (height < _phoneHeight) return 1.0;
    return 1.2;
  }

  // Get responsive height value
  static double getResponsiveHeightValue(
      BuildContext context, double baseValue) {
    return baseValue * getHeightScaleFactor(context);
  }

  static double smallHeight(BuildContext context) {
    return getResponsiveHeightValue(context, 8);
  }

  static double mediumHeight(BuildContext context) {
    return getResponsiveHeightValue(context, 12);
  }

  static double largeHeight(BuildContext context) {
    return getResponsiveHeightValue(context, 16);
  }
}

class AppDimensionsWidth {
  // Private constructor to prevent instantiation
  AppDimensionsWidth._();

  // Screen size breakpoints
  static const double _smallPhoneWidth = 360.0;
  static const double _phoneWidth = 600.0;
  static const double _tabletWidth = 900.0;
  static const double _desktopWidth = 1200.0;

  // Base spacing unit
  static const double _baseSpacing = 8.0;

  // Responsive width scaling factors
  static double _getWidthScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < _smallPhoneWidth) return 0.8;
    if (width < _phoneWidth) return 1.0;
    if (width < _tabletWidth) return 1.2;
    if (width < _desktopWidth) return 1.5;
    return 1.8; // Large desktop
  }

  // Get responsive spacing value
  static double _getResponsiveValue(BuildContext context, double baseValue) {
    return baseValue * _getWidthScaleFactor(context);
  }

  /// Spacing values - all are responsive by default
  /// Extra extra small spacing (2dp on phone)
  static double xxs(BuildContext context) =>
      _getResponsiveValue(context, _baseSpacing * 0.25);

  /// Extra small spacing (4dp on phone)
  static double xs(BuildContext context) =>
      _getResponsiveValue(context, _baseSpacing * 0.5);

  /// Small spacing (8dp on phone)
  static double s(BuildContext context) =>
      _getResponsiveValue(context, _baseSpacing);

  /// Medium spacing (12dp on phone)
  static double m(BuildContext context) =>
      _getResponsiveValue(context, _baseSpacing * 1.5);

  /// Large spacing (16dp on phone)
  static double l(BuildContext context) =>
      _getResponsiveValue(context, _baseSpacing * 2);

  /// Extra large spacing (24dp on phone)
  static double xl(BuildContext context) =>
      _getResponsiveValue(context, _baseSpacing * 3);

  /// Extra extra large spacing (32dp on phone)
  static double xxl(BuildContext context) =>
      _getResponsiveValue(context, _baseSpacing * 4);

  /// Extra extra extra large spacing (48dp on phone)
  static double xxxl(BuildContext context) =>
      _getResponsiveValue(context, _baseSpacing * 6);

  /// Border radius values - all are responsive by default
  static double borderRadiusSmall(BuildContext context) =>
      _getResponsiveValue(context, 4.0);

  static double borderRadiusMedium(BuildContext context) =>
      _getResponsiveValue(context, 8.0);

  static double borderRadiusLarge(BuildContext context) =>
      _getResponsiveValue(context, 16.0);

  static double borderRadiusXLarge(BuildContext context) =>
      _getResponsiveValue(context, 24.0);

  static double borderRadiusCircular(BuildContext context) =>
      _getResponsiveValue(context, 100.0);

  /// Icon sizes - all are responsive by default
  static double iconSizeSmall(BuildContext context) =>
      _getResponsiveValue(context, 16.0);

  static double iconSizeMedium(BuildContext context) =>
      _getResponsiveValue(context, 24.0);

  static double iconSizeLarge(BuildContext context) =>
      _getResponsiveValue(context, 32.0);

  static double iconSizeXLarge(BuildContext context) =>
      _getResponsiveValue(context, 48.0);

  /// Button heights - all are responsive by default
  static double buttonHeightSmall(BuildContext context) =>
      _getResponsiveValue(context, 32.0);

  static double buttonHeightMedium(BuildContext context) =>
      _getResponsiveValue(context, 44.0);

  static double buttonHeightLarge(BuildContext context) =>
      _getResponsiveValue(context, 56.0);

  /// Card elevations - all are responsive by default
  static double cardElevation(BuildContext context) =>
      _getResponsiveValue(context, 2.0);

  static double cardElevationLarge(BuildContext context) =>
      _getResponsiveValue(context, 4.0);

  /// Common padding values
  static EdgeInsets screenPadding(BuildContext context) {
    return EdgeInsets.symmetric(horizontal: l(context));
  }

  static EdgeInsets contentPadding(BuildContext context) {
    return EdgeInsets.all(m(context));
  }

  static EdgeInsets listItemPadding(BuildContext context) {
    return EdgeInsets.symmetric(horizontal: l(context), vertical: m(context));
  }

  static EdgeInsets cardPadding(BuildContext context) {
    return EdgeInsets.all(l(context));
  }

  static EdgeInsets buttonPadding(BuildContext context) {
    return EdgeInsets.symmetric(horizontal: l(context), vertical: s(context));
  }

  /// Returns a responsive item size for grids and lists based on screen size
  static double getResponsiveItemSize(BuildContext context,
      {double defaultSize = 100.0}) {
    return defaultSize * _getWidthScaleFactor(context);
  }

  /// Returns the number of grid columns based on screen width
  static int getResponsiveGridCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < _phoneWidth) return 2; // Phone
    if (width < _tabletWidth) return 3; // Small tablet
    if (width < _desktopWidth) return 4; // Large tablet
    return 5; // Desktop
  }

  // Legacy methods for backwards compatibility
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return screenPadding(context);
  }

  static double getResponsiveHorizontalSpacing(BuildContext context) {
    return l(context);
  }

  static double getResponsiveVerticalSpacing(BuildContext context) {
    return l(context);
  }
}
