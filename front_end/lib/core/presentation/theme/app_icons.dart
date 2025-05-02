import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A class that provides custom SVG icons for the application
/// This centralizes all icon definitions and ensures consistency
class AppIcons {
  // Private constructor to prevent instantiation
  AppIcons._();

  // Constants for icon sizes
  static const double sizeSmall = 16.0;
  static const double sizeMedium = 24.0;
  static const double sizeLarge = 32.0;
  static const double sizeXL = 40.0;

  // Helper method to create a colored SVG icon
  static Widget svg(
    String assetName, {
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return SvgPicture.asset(
      'assets/icons/$assetName.svg',
      width: width ?? sizeMedium,
      height: height ?? sizeMedium,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      fit: fit,
    );
  }

  // Account tab icons
  static Widget person({double? size, Color? color}) => svg(
        'person',
        width: size,
        height: size,
        color: color,
      );

  static Widget security({double? size, Color? color}) => svg(
        'security',
        width: size,
        height: size,
        color: color,
      );

  static Widget payment({double? size, Color? color}) => svg(
        'payment',
        width: size,
        height: size,
        color: color,
      );

  static Widget location({double? size, Color? color}) => svg(
        'location',
        width: size,
        height: size,
        color: color,
      );

  // Grocery tab icons
  static Widget shoppingBag({double? size, Color? color}) => svg(
        'shopping_bag',
        width: size,
        height: size,
        color: color,
      );

  static Widget checkCircle({double? size, Color? color}) => svg(
        'check_circle',
        width: size,
        height: size,
        color: color,
      );

  static Widget history({double? size, Color? color}) => svg(
        'history',
        width: size,
        height: size,
        color: color,
      );

  static Widget delivery({double? size, Color? color}) => svg(
        'delivery',
        width: size,
        height: size,
        color: color,
      );

  static Widget favorite({double? size, Color? color}) => svg(
        'favorite',
        width: size,
        height: size,
        color: color,
      );

  static Widget shoppingCart({double? size, Color? color}) => svg(
        'shopping_cart',
        width: size,
        height: size,
        color: color,
      );

  static Widget car({double? size, Color? color}) => svg(
        'car',
        width: size,
        height: size,
        color: color,
      );

  // Settings tab icons
  static Widget notifications({double? size, Color? color}) => svg(
        'notifications',
        width: size,
        height: size,
        color: color,
      );

  static Widget language({double? size, Color? color}) => svg(
        'language',
        width: size,
        height: size,
        color: color,
      );

  static Widget darkMode({double? size, Color? color}) => svg(
        'dark_mode',
        width: size,
        height: size,
        color: color,
      );

  static Widget privacy({double? size, Color? color}) => svg(
        'privacy',
        width: size,
        height: size,
        color: color,
      );

  static Widget help({double? size, Color? color}) => svg(
        'help',
        width: size,
        height: size,
        color: color,
      );

  static Widget info({double? size, Color? color}) => svg(
        'info',
        width: size,
        height: size,
        color: color,
      );

  static Widget star({double? size, Color? color}) => svg(
        'star',
        width: size,
        height: size,
        color: color,
      );

  static Widget share({double? size, Color? color}) => svg(
        'share',
        width: size,
        height: size,
        color: color,
      );

  // Tasks tab icons
  static Widget postAdd({double? size, Color? color}) => svg(
        'post_add',
        width: size,
        height: size,
        color: color,
      );

  static Widget assignmentTurnedIn({double? size, Color? color}) => svg(
        'assignment_turned_in',
        width: size,
        height: size,
        color: color,
      );

  static Widget engineering({double? size, Color? color}) => svg(
        'engineering',
        width: size,
        height: size,
        color: color,
      );

  static Widget visibility({double? size, Color? color}) => svg(
        'visibility',
        width: size,
        height: size,
        color: color,
      );

  // Profile settings screen icons
  static Widget personOutline({double? size, Color? color}) => svg(
        'person_outline',
        width: size,
        height: size,
        color: color,
      );

  static Widget assignmentOutline({double? size, Color? color}) => svg(
        'assignment_outline',
        width: size,
        height: size,
        color: color,
      );

  static Widget shoppingBasket({double? size, Color? color}) => svg(
        'shopping_basket',
        width: size,
        height: size,
        color: color,
      );

  static Widget settings({double? size, Color? color}) => svg(
        'settings2',
        width: size,
        height: size,
        color: color,
      );

  // Other common icons
  static Widget message({double? size, Color? color}) => svg(
        'message',
        width: size,
        height: size,
        color: color,
      );

  static Widget cart({double? size, Color? color}) => svg(
        'cart',
        width: size,
        height: size,
        color: color,
      );

  static Widget home({double? size, Color? color}) => svg(
        'home',
        width: size,
        height: size,
        color: color,
      );
}
