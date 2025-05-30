import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_constant.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/core/presentation/widgets/buttons/button_factory.dart';

/// Widget for the add to cart button with price display
class CommunityOrderButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool showIcon;
  final Color backgroundColor;
  final double textSize;
  final Color textColor;

  const CommunityOrderButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.showIcon = true,
    required this.backgroundColor,
    required this.textSize,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonFactory.createAnimatedButton(
        context: context,
        onPressed: onPressed,
        text: "",
        childText: _buildTextAndIcon(),
        backgroundColor: backgroundColor,
        textColor: textColor,
        splashColor: backgroundColor,
        highlightColor: backgroundColor,
        boxShadowColor: backgroundColor,
        minWidth: AppButtonDimensions.minWidth,
        minHeight: AppButtonDimensions.minHeight,
        verticalPadding: AppDimensionsWidth.xSmall,
        horizontalPadding: AppDimensionsHeight.small,
        borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
        animationDuration:
            Duration(milliseconds: AppConstant.buttonAnimationDurationMs),
        enableHapticFeedback: true,
        textStyle: null);
  }

  Widget _buildTextAndIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side - text
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ),
        // Right side - icon
        showIcon
            ? Icon(Icons.calendar_month, size: 20, color: textColor)
            : const SizedBox()
      ],
    );
  }
}
