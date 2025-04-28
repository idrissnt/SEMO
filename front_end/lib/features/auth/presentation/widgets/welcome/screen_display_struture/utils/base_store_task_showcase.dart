import 'package:flutter/material.dart';

import 'package:semo/core/presentation/theme/theme_services/app_colors.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';

import 'package:semo/features/auth/presentation/widgets/welcome/components/auth_buttons.dart';

/// A base component for showcase cards that provides a consistent layout structure
class BaseShowcase extends StatelessWidget {
  /// The title text or widget to display at the top
  final Widget titleSection;

  /// The main content to display in the middle
  final Widget contentSection;

  /// Custom padding for the entire card
  final EdgeInsets? padding;

  /// Background color of the card
  final Color backgroundColor;

  const BaseShowcase({
    Key? key,
    required this.titleSection,
    required this.contentSection,
    this.padding,
    this.backgroundColor = AppColors.secondary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: backgroundColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
        ),
        child: Padding(
          padding: padding ??
              EdgeInsets.symmetric(
                vertical: AppDimensionsHeight.xl,
                horizontal: AppDimensionsWidth.medium,
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title section
              titleSection,

              // Content section
              contentSection,

              // Auth buttons section
              const AuthButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
