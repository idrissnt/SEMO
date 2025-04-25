import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/theme_services/previous/app_dimensions.dart';

/// A centralized class for managing icons and their responsive sizes throughout the app.
/// This ensures consistent icon usage and sizing across different screen sizes.
class AppIcons {
  /// Icons with different sizes
  static Icon iconMedium(BuildContext context,
          {required IconData icon, Color? color}) =>
      Icon(
        icon,
        size: AppDimensionsWidth.iconSizeMediumWidth(context),
        color: color,
      );

  static Icon iconSmall(BuildContext context,
          {required IconData icon, Color? color}) =>
      Icon(
        icon,
        size: AppDimensionsWidth.iconSizeSmallWidth(context),
        color: color,
      );

  static Icon iconLarge(BuildContext context,
          {required IconData icon, Color? color}) =>
      Icon(
        icon,
        size: AppDimensionsWidth.iconSizeLargeWidth(context),
        color: color,
      );

  static Icon iconXLarge(BuildContext context,
          {required IconData icon, Color? color}) =>
      Icon(
        icon,
        size: AppDimensionsWidth.iconSizeXLargeWidth(context),
        color: color,
      );
}
