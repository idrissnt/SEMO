import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/core/presentation/widgets/buttons/animated_button.dart';
import 'package:semo/core/presentation/widgets/buttons/loading_button.dart';

/// A factory class for creating consistent buttons throughout the app
///
/// This factory provides methods to create different types of buttons with
/// consistent styling and behavior, following the app's design system.
class ButtonFactory {
  /// Creates a standard animated button with the specified parameters
  static Widget createAnimatedButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required String text,
    Widget? childText,
    required Color backgroundColor,
    required Color textColor,
    required Color splashColor,
    required Color highlightColor,
    required Color boxShadowColor,
    double? minWidth,
    double? minHeight,
    double? verticalPadding,
    double? horizontalPadding,
    BorderRadius? borderRadius,
    Duration? animationDuration,
    bool enableHapticFeedback = true,
    TextStyle? textStyle,
  }) {
    final effectiveVerticalPadding =
        verticalPadding ?? AppDimensionsWidth.xSmall;
    final effectiveHorizontalPadding =
        horizontalPadding ?? AppDimensionsHeight.small;
    final effectiveMinWidth = minWidth ?? 200.w;
    final effectiveMinHeight = minHeight ?? 48.h;
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppBorderRadius.xxl);
    final effectiveAnimationDuration =
        animationDuration ?? const Duration(milliseconds: 300);

    return AnimatedButton(
      onPressed: onPressed,
      splashColor: splashColor,
      highlightColor: highlightColor,
      boxShadowColor: boxShadowColor,
      animationDuration: effectiveAnimationDuration,
      enableHapticFeedback: enableHapticFeedback,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: effectiveBorderRadius,
        ),
        padding: EdgeInsets.symmetric(
          vertical: effectiveVerticalPadding,
          horizontal: effectiveHorizontalPadding,
        ),
        minimumSize: Size(effectiveMinWidth, effectiveMinHeight),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
      ),
      child: SizedBox(
        width: effectiveMinWidth,
        child: childText ??
            Text(
              text,
              textAlign: TextAlign.center,
              style: textStyle ??
                  TextStyle(
                    color: textColor,
                    fontSize: AppFontSize.large,
                    fontWeight: FontWeight.w800,
                  ),
            ),
      ),
    );
  }

  /// Creates a loading button with the specified parameters
  static Widget createLoadingButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required String text,
    required bool isLoading,
    required Color backgroundColor,
    required Color textColor,
    required Color splashColor,
    required Color highlightColor,
    required Color boxShadowColor,
    double? minWidth,
    double? minHeight,
    double? verticalPadding,
    double? horizontalPadding,
    BorderRadius? borderRadius,
    Duration? animationDuration,
    bool enableHapticFeedback = true,
    TextStyle? textStyle,
  }) {
    final effectiveVerticalPadding =
        verticalPadding ?? AppDimensionsWidth.xSmall;
    final effectiveHorizontalPadding =
        horizontalPadding ?? AppDimensionsHeight.small;
    final effectiveMinWidth = minWidth ?? 200.w;
    final effectiveMinHeight = minHeight ?? 48.h;
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppBorderRadius.xxl);
    final effectiveAnimationDuration =
        animationDuration ?? const Duration(milliseconds: 300);

    return LoadingButton(
      onPressed: onPressed,
      isLoading: isLoading,
      splashColor: splashColor,
      highlightColor: highlightColor,
      boxShadowColor: boxShadowColor,
      animationDuration: effectiveAnimationDuration,
      enableHapticFeedback: enableHapticFeedback,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: effectiveBorderRadius,
        ),
        padding: EdgeInsets.symmetric(
          vertical: effectiveVerticalPadding,
          horizontal: effectiveHorizontalPadding,
        ),
        minimumSize: Size(effectiveMinWidth, effectiveMinHeight),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
      ),
      child: SizedBox(
        width: effectiveMinWidth,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: textStyle ??
              TextStyle(
                color: textColor,
                fontSize: AppFontSize.large,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }

  /// Creates a navigation button that navigates to a specified route
  static Widget createNavigationButton({
    required BuildContext context,
    required String route,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required Color splashColor,
    required Color highlightColor,
    required Color boxShadowColor,
    double? minWidth,
    double? minHeight,
    double? verticalPadding,
    double? horizontalPadding,
    BorderRadius? borderRadius,
    Duration? animationDuration,
    bool enableHapticFeedback = true,
    TextStyle? textStyle,
    Map<String, dynamic>? routeParams,
  }) {
    return createAnimatedButton(
      context: context,
      onPressed: () {
        if (routeParams != null) {
          context.push(route, extra: routeParams);
        } else {
          context.push(route);
        }
      },
      text: text,
      backgroundColor: backgroundColor,
      textColor: textColor,
      splashColor: splashColor,
      highlightColor: highlightColor,
      boxShadowColor: boxShadowColor,
      minWidth: minWidth,
      minHeight: minHeight,
      verticalPadding: verticalPadding,
      horizontalPadding: horizontalPadding,
      borderRadius: borderRadius,
      animationDuration: animationDuration,
      enableHapticFeedback: enableHapticFeedback,
      textStyle: textStyle,
    );
  }

  /// Creates a primary button with the app's primary color scheme
  static Widget createPrimaryButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required String text,
    double? minWidth,
    double? minHeight,
    bool enableHapticFeedback = true,
  }) {
    return createAnimatedButton(
      context: context,
      onPressed: onPressed,
      text: text,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      splashColor: AppColors.primary,
      highlightColor: AppColors.primary,
      boxShadowColor: AppColors.primary,
      minWidth: minWidth,
      minHeight: minHeight,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Creates a secondary button with the app's secondary color scheme
  static Widget createSecondaryButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required String text,
    double? minWidth,
    double? minHeight,
    bool enableHapticFeedback = true,
  }) {
    return createAnimatedButton(
      context: context,
      onPressed: onPressed,
      text: text,
      backgroundColor: AppColors.secondaryVariant,
      textColor: AppColors.textPrimaryColor,
      splashColor: AppColors.secondaryVariant,
      highlightColor: AppColors.secondaryVariant,
      boxShadowColor: AppColors.secondaryVariant,
      minWidth: minWidth,
      minHeight: minHeight,
      enableHapticFeedback: enableHapticFeedback,
    );
  }
}
