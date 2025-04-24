import 'package:flutter/material.dart';
import 'theme_services/app_colors.dart';
import 'theme_services/app_dimensions.dart';
import 'theme_services/app_text_styles.dart';
import 'theme_services/app_icons.dart';

/// Extension on BuildContext to easily access theme properties
extension ThemeExtension on BuildContext {
  /// Access to app text styles
  TextStyle get semoWelcome => AppTextStyles.semoWelcome(this);
  TextStyle get headline1 => AppTextStyles.headline1(this);
  TextStyle get headline2 => AppTextStyles.headline2(this);
  TextStyle get headline3 => AppTextStyles.headline3(this);
  TextStyle get headline4 => AppTextStyles.headline4(this);
  TextStyle get sectionTitle => AppTextStyles.sectionTitle(this);
  TextStyle get bodyLarge => AppTextStyles.bodyLarge(this);
  TextStyle get appBarTitle => AppTextStyles.appBarTitle(this);
  TextStyle get bodyMedium => AppTextStyles.bodyMedium(this);
  TextStyle get bodySmall => AppTextStyles.bodySmall(this);
  TextStyle get caption => AppTextStyles.caption(this);
  TextStyle get buttonVeryLarge => AppTextStyles.buttonVeryLarge(this);
  TextStyle get buttonLarge => AppTextStyles.buttonLarge(this);
  TextStyle get buttonMedium => AppTextStyles.buttonMedium(this);
  TextStyle get buttonSmall => AppTextStyles.buttonSmall(this);
  TextStyle get errorText => AppTextStyles.errorText(this);
  TextStyle get successText => AppTextStyles.successText(this);
  TextStyle get cardTitle => AppTextStyles.cardTitle(this);
  TextStyle get cardSubtitle => AppTextStyles.cardSubtitle(this);
  TextStyle get badgeText => AppTextStyles.badgeText(this);
  TextStyle get listItemTitle => AppTextStyles.listItemTitle(this);
  TextStyle get listItemSubtitle => AppTextStyles.listItemSubtitle(this);

  /// Access to app colors
  Color get primaryColor => AppColors.primary;
  Color get secondaryColor => AppColors.secondary;
  Color get backgroundColor => AppColors.background;
  Color get surfaceColor => AppColors.surface;
  Color get errorColor => AppColors.error;
  Color get successColor => AppColors.success;
  Color get warningColor => AppColors.warning;
  Color get textPrimaryColor => AppColors.onPrimary;
  Color get textSecondaryColor => AppColors.onSecondary;
  Color get textDisabledColor => AppColors.onBackground;
  Color get textSurfaceColor => AppColors.onSurface;
  Color get lineColor => AppColors.lineColor;

  /// Access to responsive spacing dimensions
  double get xxs => AppDimensionsWidth.xxs(this);
  double get xs => AppDimensionsWidth.xs(this);
  double get s => AppDimensionsWidth.s(this);
  double get m => AppDimensionsWidth.m(this);
  double get l => AppDimensionsWidth.l(this);
  double get xl => AppDimensionsWidth.xl(this);
  double get xxl => AppDimensionsWidth.xxl(this);
  double get xxxl => AppDimensionsWidth.xxxl(this);

  /// Access to responsive height dimensions
  double get smallHeight => AppDimensionsHeight.smallHeight(this);
  double get mediumHeight => AppDimensionsHeight.mediumHeight(this);
  double get largeHeight => AppDimensionsHeight.largeHeight(this);
  double getResponsiveHeightValue(double baseValue) =>
      AppDimensionsHeight.getResponsiveHeightValue(this, baseValue);

  /// Access to responsive border radius
  double get borderRadiusSmall => AppDimensionsWidth.borderRadiusSmall(this);
  double get borderRadiusMedium => AppDimensionsWidth.borderRadiusMedium(this);
  double get borderRadiusLarge => AppDimensionsWidth.borderRadiusLarge(this);
  double get borderRadiusXLarge => AppDimensionsWidth.borderRadiusXLarge(this);
  double get borderRadiusCircular =>
      AppDimensionsWidth.borderRadiusCircular(this);

  /// Access to responsive icon sizes
  double get iconSizeSmall => AppDimensionsWidth.iconSizeSmall(this);
  double get iconSizeMedium => AppDimensionsWidth.iconSizeMedium(this);
  double get iconSizeLarge => AppDimensionsWidth.iconSizeLarge(this);
  double get iconSizeXLarge => AppDimensionsWidth.iconSizeXLarge(this);

  /// Access to responsive button heights
  double get buttonHeightSmall => AppDimensionsWidth.buttonHeightSmall(this);
  double get buttonHeightMedium => AppDimensionsWidth.buttonHeightMedium(this);
  double get buttonHeightLarge => AppDimensionsWidth.buttonHeightLarge(this);

  /// Access to responsive card elevations
  double get cardElevation => AppDimensionsWidth.cardElevation(this);
  double get cardElevationLarge => AppDimensionsWidth.cardElevationLarge(this);

  /// Access to responsive padding presets
  EdgeInsets get screenPadding => AppDimensionsWidth.screenPadding(this);
  EdgeInsets get contentPadding => AppDimensionsWidth.contentPadding(this);
  EdgeInsets get listItemPadding => AppDimensionsWidth.listItemPadding(this);
  EdgeInsets get cardPadding => AppDimensionsWidth.cardPadding(this);
  EdgeInsets get buttonPadding => AppDimensionsWidth.buttonPadding(this);

  /// Access to responsive grid and layout helpers
  int get gridCount => AppDimensionsWidth.getResponsiveGridCount(this);

  /// Get responsive item size with default size
  double responsiveItemSize(double defaultSize) =>
      AppDimensionsWidth.getResponsiveItemSize(this, defaultSize: defaultSize);

  /// For backwards compatibility
  double get horizontalSpacing => AppDimensionsWidth.l(this);

  /// Access to app icons
  Icon iconSmall({required IconData icon, Color? color}) =>
      AppIcons.iconSmall(this, icon: icon, color: color);
  Icon iconMedium({required IconData icon, Color? color}) =>
      AppIcons.iconMedium(this, icon: icon, color: color);
  Icon iconLarge({required IconData icon, Color? color}) =>
      AppIcons.iconLarge(this, icon: icon, color: color);
  Icon iconXLarge({required IconData icon, Color? color}) =>
      AppIcons.iconXLarge(this, icon: icon, color: color);
}
