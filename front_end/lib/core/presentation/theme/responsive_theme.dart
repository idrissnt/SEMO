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
  TextStyle get buttonExtraSmall => AppTextStyles.buttonExtraSmall(this);
  TextStyle get errorText => AppTextStyles.errorText(this);
  TextStyle get successText => AppTextStyles.successText(this);
  TextStyle get cardTitle => AppTextStyles.cardTitle(this);
  TextStyle get cardSubtitle => AppTextStyles.cardSubtitle(this);
  TextStyle get badgeText => AppTextStyles.badgeText(this);
  TextStyle get listItemTitle => AppTextStyles.listItemTitle(this);
  TextStyle get listItemSubtitle => AppTextStyles.listItemSubtitle(this);

  /// Access to app colors
  Color get primaryColor => AppColors.primary;
  Color get primaryVariantColor => AppColors.primaryVariant;
  Color get secondaryColor => AppColors.secondary;
  Color get secondaryVariantColor => AppColors.secondaryVariant;
  Color get backgroundColor => AppColors.background;
  Color get surfaceColor => AppColors.surface;
  Color get errorColor => AppColors.error;
  Color get successColor => AppColors.success;
  Color get warningColor => AppColors.warning;
  Color get textPrimaryColor => AppColors.textPrimaryColor;
  Color get textSecondaryColor => AppColors.textSecondaryColor;

  /// Access to responsive spacing dimensions
  double get xxsWidth => AppDimensionsWidth.xxsWidth(this);
  double get xsWidth => AppDimensionsWidth.xsWidth(this);
  double get sWidth => AppDimensionsWidth.sWidth(this);
  double get mWidth => AppDimensionsWidth.mWidth(this);
  double get lWidth => AppDimensionsWidth.lWidth(this);
  double get xlWidth => AppDimensionsWidth.xlWidth(this);
  double get xxlWidth => AppDimensionsWidth.xxlWidth(this);
  double get xxxlWidth => AppDimensionsWidth.xxxlWidth(this);
  double getResponsiveWidthValue(double baseValue) =>
      AppDimensionsWidth.getResponsiveWidthValue(this, baseValue);

  /// Access to responsive height dimensions
  double get extraSmallHeight => AppDimensionsHeight.extraSmallHeight(this);
  double get smallHeight => AppDimensionsHeight.smallHeight(this);
  double get mediumHeight => AppDimensionsHeight.mediumHeight(this);
  double get largeHeight => AppDimensionsHeight.largeHeight(this);
  double getResponsiveHeightValue(double baseValue) =>
      AppDimensionsHeight.getResponsiveHeightValue(this, baseValue);
  double get xLargeHeight => AppDimensionsHeight.xLargeHeight(this);
  double get xxLargeHeight => AppDimensionsHeight.xxLargeHeight(this);

  /// Access to responsive button heights
  double get buttonHeightSmallWidth =>
      AppDimensionsHeight.buttonHeightSmall(this);
  double get buttonHeightMediumWidth =>
      AppDimensionsHeight.buttonHeightMedium(this);
  double get buttonHeightLargeWidth =>
      AppDimensionsHeight.buttonHeightLarge(this);

  /// Access to responsive border radius
  double get borderRadiusSmallWidth =>
      AppDimensionsWidth.borderRadiusSmallWidth(this);
  double get borderRadiusMediumWidth =>
      AppDimensionsWidth.borderRadiusMediumWidth(this);
  double get borderRadiusLargeWidth =>
      AppDimensionsWidth.borderRadiusLargeWidth(this);
  double get borderRadiusXLargeWidth =>
      AppDimensionsWidth.borderRadiusXLargeWidth(this);
  double get borderRadiusXXLargeWidth =>
      AppDimensionsWidth.borderRadiusXXLargeWidth(this);
  double get borderRadiusCircularWidth =>
      AppDimensionsWidth.borderRadiusCircularWidth(this);

  /// Access to responsive icon sizes
  double get iconSizeSmallWidth => AppDimensionsWidth.iconSizeSmallWidth(this);
  double get iconSizeMediumWidth =>
      AppDimensionsWidth.iconSizeMediumWidth(this);
  double get iconSizeLargeWidth => AppDimensionsWidth.iconSizeLargeWidth(this);
  double get iconSizeXLargeWidth =>
      AppDimensionsWidth.iconSizeXLargeWidth(this);

  /// Access to responsive card elevations
  double get cardElevationWidth => AppDimensionsWidth.cardElevationWidth(this);
  double get cardElevationLargeWidth =>
      AppDimensionsWidth.cardElevationLargeWidth(this);

  /// Access to responsive padding presets
  EdgeInsets get screenPaddingWidth =>
      AppDimensionsWidth.screenPaddingWidth(this);
  EdgeInsets get contentPaddingWidth =>
      AppDimensionsWidth.contentPaddingWidth(this);
  EdgeInsets get listItemPaddingWidth =>
      AppDimensionsWidth.listItemPaddingWidth(this);
  EdgeInsets get cardPaddingWidth => AppDimensionsWidth.cardPaddingWidth(this);
  EdgeInsets get buttonPaddingWidth =>
      AppDimensionsWidth.buttonPaddingWidth(this);

  /// Access to responsive grid and layout helpers
  int get gridCount => AppDimensionsWidth.getResponsiveGridCountWidth(this);

  /// Get responsive item size with default size
  double responsiveItemSizeWidth(double defaultSize) =>
      AppDimensionsWidth.getResponsiveItemSizeWidth(this,
          defaultSize: defaultSize);

  /// For backwards compatibility
  double get horizontalSpacingWidth => AppDimensionsWidth.lWidth(this);

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
