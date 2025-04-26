import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';

/// A builder class for creating consistent buttons throughout the app
class ButtonBuilder {
  final BuildContext context;
  final String route;
  final String text;
  final Color textColor;
  final Color backgroundColor;
  final Color foregroundColor;
  final double verticalPadding;
  final double horizontalPadding;
  final double minWidth;
  final double minHeight;

  /// Creates a ButtonBuilder with all required parameters for button styling
  ButtonBuilder({
    required this.context,
    required this.route,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.minWidth,
    required this.minHeight,
  });

  /// Builds and returns an ElevatedButton with the specified styling
  Widget buildButtons() {
    return ElevatedButton(
      onPressed: () => context.push(route),
      style: ElevatedButton.styleFrom(
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
