import 'package:flutter/cupertino.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';

/// A class that provides Cupertino icons for the application
/// This centralizes all icon definitions and ensures consistency
class AppIcons {
  // Private constructor to prevent instantiation
  AppIcons._();

  // Constants for icon sizes
  static double sizeSmall = AppIconSize.small;
  static double sizeMedium = AppIconSize.medium;
  static double sizeLarge = AppIconSize.large;
  static double sizeXL = AppIconSize.xl;

  // Helper method to create an icon with the given parameters
  static Widget _buildIcon(IconData iconData, {double? size, Color? color}) {
    return Icon(
      iconData,
      size: size ?? sizeMedium,
      color: color,
    );
  }

  static Widget chevronForward({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.chevron_forward,
        size: size,
        color: color,
      );

  static Widget photoCameraSolid({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.photo_camera_solid,
        size: size,
        color: color,
      );

  static Widget addPersonToShopWith({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.person_add_solid,
        size: size,
        color: color,
      );

  // Account tab icons
  static Widget person({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.person_fill,
        size: size,
        color: color,
      );

  static Widget security({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.shield_fill,
        size: size,
        color: color,
      );

  static Widget payment({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.creditcard_fill,
        size: size,
        color: color,
      );

  static Widget location({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.location_solid,
        size: size,
        color: color,
      );

  // Grocery tab icons
  static Widget shoppingBagFill({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.bag_fill,
        size: size,
        color: color,
      );

  static Widget checkCircle({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.checkmark_circle_fill,
        size: size,
        color: color,
      );

  static Widget history({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.clock_fill,
        size: size,
        color: color,
      );

  static Widget delivery({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.cube_box_fill,
        size: size,
        color: color,
      );

  static Widget favorite({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.heart_fill,
        size: size,
        color: color,
      );

  static Widget shoppingCart({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.cart_fill,
        size: size,
        color: color,
      );

  static Widget car({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.car_fill,
        size: size,
        color: color,
      );

  // Settings tab icons
  static Widget notifications({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.bell_fill,
        size: size,
        color: color,
      );

  static Widget language({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.globe,
        size: size,
        color: color,
      );

  static Widget darkMode({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.moon_fill,
        size: size,
        color: color,
      );

  static Widget privacy({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.lock_fill,
        size: size,
        color: color,
      );

  static Widget help({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.question_circle_fill,
        size: size,
        color: color,
      );

  static Widget info({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.info_circle_fill,
        size: size,
        color: color,
      );

  static Widget star({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.star_fill,
        size: size,
        color: color,
      );

  static Widget share({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.share,
        size: size,
        color: color,
      );

  // Tasks tab icons
  static Widget postAdd({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.rocket_fill,
        size: size,
        color: color,
      );

  static Widget assignmentTurnedIn({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.checkmark_square_fill,
        size: size,
        color: color,
      );

  static Widget currentTask({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.arrow_2_circlepath_circle_fill,
        size: size,
        color: color,
      );

  static Widget performedTask({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.checkmark_circle_fill,
        size: size,
        color: color,
      );

  static Widget visibility({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.eye_fill,
        size: size,
        color: color,
      );

  // Profile settings screen icons
  static Widget personOutline({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.person,
        size: size,
        color: color,
      );

  static Widget assignmentFilled({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.hammer_fill,
        size: size,
        color: color,
      );

  static Widget shoppingBag({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.bag,
        size: size,
        color: color,
      );

  static Widget settings({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.gear_alt_fill,
        size: size,
        color: color,
      );

  // Other common icons
  static Widget message({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.chat_bubble_fill,
        size: size,
        color: color,
      );

  static Widget cart({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.cart_fill,
        size: size,
        color: color,
      );

  static Widget home({double? size, Color? color}) => _buildIcon(
        CupertinoIcons.house_fill,
        size: size,
        color: color,
      );
}
