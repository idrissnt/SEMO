import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/features/home/presentation/constant/home_constants.dart';

/// A reusable action icon button with consistent styling
/// Used across app bar components to ensure visual consistency
class ActionIconButton extends StatelessWidget {
  /// The icon to display
  final IconData icon;

  /// Function to execute when the button is pressed
  final VoidCallback onPressed;

  /// Optional color for the icon
  final Color? color;

  /// Optional size for the icon
  final double? size;

  /// Optional tooltip text for accessibility
  final String? tooltip;

  /// Constructor for ActionIconButton
  const ActionIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon,
          color: color ?? AppColors.iconColorFirstColor,
          size: size ?? AppIconSize.xl),
      onPressed: onPressed,
      tooltip: tooltip,
      // padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      iconSize: size ?? AppIconSize.xl,
      visualDensity: VisualDensity(
          horizontal: HomeConstants.horizontalDensityBetweenIconAndText,
          vertical: 0),
    );
  }
}
