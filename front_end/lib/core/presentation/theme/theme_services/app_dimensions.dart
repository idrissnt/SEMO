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

  static double xLargeHeight(BuildContext context) {
    return getResponsiveHeightValue(context, 20);
  }

  static double xxLargeHeight(BuildContext context) {
    return getResponsiveHeightValue(context, 24);
  }

  /// Button heights - all are responsive by default
  static double buttonHeightSmall(BuildContext context) =>
      getResponsiveHeightValue(context, 32.0);

  static double buttonHeightMedium(BuildContext context) =>
      getResponsiveHeightValue(context, 44.0);

  static double buttonHeightLarge(BuildContext context) =>
      getResponsiveHeightValue(context, 56.0);
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
  static double getResponsiveWidthValue(
      BuildContext context, double baseValue) {
    return baseValue * _getWidthScaleFactor(context);
  }

  /// Spacing values - all are responsive by default
  /// Extra extra small spacing (2dp on phone)
  static double xxsWidth(BuildContext context) =>
      getResponsiveWidthValue(context, _baseSpacing * 0.25);

  /// Extra small spacing (4dp on phone)
  static double xsWidth(BuildContext context) =>
      getResponsiveWidthValue(context, _baseSpacing * 0.5);

  /// Small spacing (8dp on phone)
  static double sWidth(BuildContext context) =>
      getResponsiveWidthValue(context, _baseSpacing);

  /// Medium spacing (12dp on phone)
  static double mWidth(BuildContext context) =>
      getResponsiveWidthValue(context, _baseSpacing * 1.5);

  /// Large spacing (16dp on phone)
  static double lWidth(BuildContext context) =>
      getResponsiveWidthValue(context, _baseSpacing * 2);

  /// Extra large spacing (24dp on phone)
  static double xlWidth(BuildContext context) =>
      getResponsiveWidthValue(context, _baseSpacing * 3);

  /// Extra extra large spacing (32dp on phone)
  static double xxlWidth(BuildContext context) =>
      getResponsiveWidthValue(context, _baseSpacing * 4);

  /// Extra extra extra large spacing (48dp on phone)
  static double xxxlWidth(BuildContext context) =>
      getResponsiveWidthValue(context, _baseSpacing * 6);

  /// Border radius values - all are responsive by default
  static double borderRadiusSmallWidth(BuildContext context) =>
      getResponsiveWidthValue(context, 4.0);

  static double borderRadiusMediumWidth(BuildContext context) =>
      getResponsiveWidthValue(context, 8.0);

  static double borderRadiusLargeWidth(BuildContext context) =>
      getResponsiveWidthValue(context, 16.0);

  static double borderRadiusXLargeWidth(BuildContext context) =>
      getResponsiveWidthValue(context, 24.0);

  static double borderRadiusXXLargeWidth(BuildContext context) =>
      getResponsiveWidthValue(context, 33.0);

  static double borderRadiusCircularWidth(BuildContext context) =>
      getResponsiveWidthValue(context, 100.0);

  /// Icon sizes - all are responsive by default
  static double iconSizeSmallWidth(BuildContext context) =>
      getResponsiveWidthValue(context, 16.0);

  static double iconSizeMediumWidth(BuildContext context) =>
      getResponsiveWidthValue(context, 24.0);

  static double iconSizeLargeWidth(BuildContext context) =>
      getResponsiveWidthValue(context, 32.0);

  static double iconSizeXLargeWidth(BuildContext context) =>
      getResponsiveWidthValue(context, 48.0);

  /// Card elevations - all are responsive by default
  static double cardElevationWidth(BuildContext context) =>
      getResponsiveWidthValue(context, 2.0);

  static double cardElevationLargeWidth(BuildContext context) =>
      getResponsiveWidthValue(context, 4.0);

  /// Common padding values
  static EdgeInsets screenPaddingWidth(BuildContext context) {
    return EdgeInsets.symmetric(horizontal: lWidth(context));
  }

  static EdgeInsets contentPaddingWidth(BuildContext context) {
    return EdgeInsets.all(mWidth(context));
  }

  static EdgeInsets listItemPaddingWidth(BuildContext context) {
    return EdgeInsets.symmetric(
        horizontal: lWidth(context), vertical: mWidth(context));
  }

  static EdgeInsets cardPaddingWidth(BuildContext context) {
    return EdgeInsets.all(lWidth(context));
  }

  static EdgeInsets buttonPaddingWidth(BuildContext context) {
    return EdgeInsets.symmetric(
        horizontal: lWidth(context), vertical: sWidth(context));
  }

  /// Returns a responsive item size for grids and lists based on screen size
  static double getResponsiveItemSizeWidth(BuildContext context,
      {double defaultSize = 100.0}) {
    return defaultSize * _getWidthScaleFactor(context);
  }

  /// Returns the number of grid columns based on screen width
  static int getResponsiveGridCountWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < _phoneWidth) return 2; // Phone
    if (width < _tabletWidth) return 3; // Small tablet
    if (width < _desktopWidth) return 4; // Large tablet
    return 5; // Desktop
  }

  // Legacy methods for backwards compatibility
  static EdgeInsets getResponsivePaddingWidth(BuildContext context) {
    return screenPaddingWidth(context);
  }

  static double getResponsiveHorizontalSpacingWidth(BuildContext context) {
    return lWidth(context);
  }

  static double getResponsiveVerticalSpacingWidth(BuildContext context) {
    return lWidth(context);
  }
}
