import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';
import 'package:semo/features/auth/presentation/widgets/shared/animated_button.dart';

/// A builder class for creating consistent animated buttons throughout the app
class AnimatedButtonBuilder {
  final BuildContext context;
  final String route;
  final String text;
  final Color textColor;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color splashColor;
  final Color boxShadowColor;
  final Color highlightColor;
  final double verticalPadding;
  final double horizontalPadding;
  final double minWidth;
  final double minHeight;
  final Duration animationDuration;
  final bool enableHapticFeedback;

  /// Creates an AnimatedButtonBuilder with all required parameters for button styling
  AnimatedButtonBuilder({
    required this.context,
    required this.route,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.splashColor,
    required this.boxShadowColor,
    required this.highlightColor,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.minWidth,
    required this.minHeight,
    this.animationDuration = const Duration(milliseconds: 300),
    this.enableHapticFeedback = true,
  });

  /// Builds and returns an AnimatedButton with the specified styling
  Widget buildButton() {
    return AnimatedButton(
      onPressed: () => context.push(route),
      splashColor: splashColor,
      highlightColor: highlightColor,
      boxShadowColor: boxShadowColor,
      animationDuration: animationDuration,
      enableHapticFeedback: enableHapticFeedback,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
        ),
        padding: EdgeInsets.symmetric(
            vertical: verticalPadding, horizontal: horizontalPadding),
        minimumSize: Size(minWidth, minHeight),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
      child: SizedBox(
        width: minWidth,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: AppFontSize.large,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
