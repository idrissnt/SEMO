import 'package:flutter/widgets.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/core/presentation/widgets/icons/action_icon_button.dart';

buildIcon({
  bool isScrolled = false,
  double scrollProgress = 0.0,
  double containerSize = 35,
  required IconData icon,
  required Color iconColor,
  required Color backgroundColor,
  required VoidCallback onPressed,
}) {
  return Container(
    padding: const EdgeInsets.all(0),
    height: isScrolled
        ? containerSize * (1.0 - scrollProgress.clamp(0.0, 1.0))
        : containerSize,
    width: isScrolled
        ? containerSize * (1.0 - scrollProgress.clamp(0.0, 1.0))
        : containerSize,
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: ActionIconButton(
      icon: icon,
      color: iconColor,
      onPressed: onPressed,
      size: isScrolled
          ? AppIconSize.xl * (1.0 - scrollProgress.clamp(0.0, 1.0))
          : AppIconSize.xl,
    ),
  );
}
