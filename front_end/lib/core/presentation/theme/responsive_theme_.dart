import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'theme_services/app_colors.dart';
import 'theme_services/app_text_styles.dart';

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

  /// Access to responsive spacing dimensions using ScreenUtil
  double get xxsWidth => 4.w;
  double get xsWidth => 8.w;
  double get sWidth => 12.w;
  double get mWidth => 16.w;
  double get lWidth => 24.w;
  double get xlWidth => 32.w;
  double get xxlWidth => 48.w;
  double get xxxlWidth => 64.w;
  double getResponsiveWidthValue(double baseValue) => baseValue.w;

  /// Access to responsive height dimensions using ScreenUtil
  double get extraSmallHeight => 4.h * 1.2;
  double get smallHeight => 8.h * 1.2;
  double get mediumHeight => 16.h * 1.2;
  double get largeHeight => 24.h * 1.2;
  double getResponsiveHeightValue(double baseValue) => baseValue.h * 1.2;
  double get xLargeHeight => 32.h * 1.2;
  double get xxLargeHeight => 48.h * 1.2;

  /// Access to responsive button heights using ScreenUtil
  double get buttonHeightSmallWidth => 36.h;
  double get buttonHeightMediumWidth => 48.h;
  double get buttonHeightLargeWidth => 56.h;

  /// Access to responsive border radius using ScreenUtil
  double get borderRadiusSmallWidth => 4.r;
  double get borderRadiusMediumWidth => 8.r;
  double get borderRadiusLargeWidth => 12.r;
  double get borderRadiusXLargeWidth => 16.r;
  double get borderRadiusXXLargeWidth => 24.r;
  double get borderRadiusCircularWidth => 100.r;

  /// Access to responsive icon sizes using ScreenUtil
  double get iconSizeSmallWidth => 16.r;
  double get iconSizeMediumWidth => 24.r;
  double get iconSizeLargeWidth => 32.r;
  double get iconSizeXLargeWidth => 48.r;

  /// Access to responsive card elevations using ScreenUtil
  double get cardElevationWidth => 2.r;
  double get cardElevationLargeWidth => 4.r;

  /// Access to responsive padding presets using ScreenUtil
  EdgeInsets get screenPaddingWidth =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h);
  EdgeInsets get contentPaddingWidth => EdgeInsets.all(16.r);
  EdgeInsets get listItemPaddingWidth =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);
  EdgeInsets get cardPaddingWidth => EdgeInsets.all(16.r);
  EdgeInsets get buttonPaddingWidth =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h);

  /// Access to responsive grid and layout helpers using ScreenUtil
  int get gridCount {
    final width = ScreenUtil().screenWidth;
    if (width < 600) return 2;
    if (width < 900) return 3;
    return 4;
  }

  /// Get responsive item size with default size using ScreenUtil
  double responsiveItemSizeWidth(double defaultSize) => defaultSize.w;

  /// For backwards compatibility
  double get horizontalSpacingWidth => 24.w;

  /// Access to app icons using ScreenUtil
  Icon iconSmall({required IconData icon, Color? color}) =>
      Icon(icon, size: 16.r, color: color);
  Icon iconMedium({required IconData icon, Color? color}) =>
      Icon(icon, size: 24.r, color: color);
  Icon iconLarge({required IconData icon, Color? color}) =>
      Icon(icon, size: 32.r, color: color);
  Icon iconXLarge({required IconData icon, Color? color}) =>
      Icon(icon, size: 48.r, color: color);
}
