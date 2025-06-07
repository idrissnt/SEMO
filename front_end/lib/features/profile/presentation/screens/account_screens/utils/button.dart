import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/core/presentation/widgets/buttons/button_factory.dart';

Widget createVerificationButton({
  required BuildContext context,
  required Function onPressed,
  required String text,
}) {
  return ButtonFactory.createAnimatedButton(
    context: context,
    onPressed: () => onPressed(),
    text: text,
    backgroundColor: AppColors.primary,
    textColor: AppColors.textSecondaryColor,
    splashColor: AppColors.primary,
    highlightColor: AppColors.primary,
    boxShadowColor: AppColors.primary,
    minWidth: AppButtonDimensions.minWidth,
    minHeight: AppButtonDimensions.minHeight,
    verticalPadding: AppDimensionsWidth.xSmall,
    horizontalPadding: AppDimensionsHeight.small,
  );
}
