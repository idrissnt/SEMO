import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_constant.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/core/presentation/widgets/buttons/button_factory.dart';

/// Widget for the add to cart button with price display
class AddToCartButton extends StatelessWidget {
  final String text;
  final String price;
  final VoidCallback? onPressed;
  
  const AddToCartButton({
    Key? key,
    required this.text,
    required this.price,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonFactory.createAnimatedButton(
      context: context,
      onPressed: onPressed ?? () {},
      text: "", // Empty text since we're using childText instead
      childText: _buildTextAndPrice(),
      backgroundColor: AppColors.primary,
      textColor: AppColors.secondary,
      splashColor: AppColors.primary,
      highlightColor: AppColors.primary,
      boxShadowColor: AppColors.primary,
      minWidth: AppButtonDimensions.minWidth,
      minHeight: AppButtonDimensions.minHeight,
      verticalPadding: AppDimensionsWidth.xSmall,
      horizontalPadding: AppDimensionsHeight.small,
      borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
      animationDuration:
          Duration(milliseconds: AppConstant.buttonAnimationDurationMs),
      enableHapticFeedback: true,
      textStyle: null,
    );
  }

  Widget _buildTextAndPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side - text
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFontSize.large,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary,
            ),
          ),
        ),
        // Right side - price
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
          ),
          child: Text(
            "$price€",
            style: TextStyle(
              fontSize: AppFontSize.small,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}
