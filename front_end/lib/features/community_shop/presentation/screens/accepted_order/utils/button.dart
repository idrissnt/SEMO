import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/buttons/button_factory.dart';

/// Builds the bottom action bar with either a continue button or time information
Widget buildBottomActionBar(BuildContext context, String text,
    {required Function() onPressed}) {
  return Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      height: 100,
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 34,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ButtonFactory.createAnimatedButton(
        context: context,
        onPressed: onPressed,
        text: text,
        backgroundColor: AppColors.primary,
        textColor: Colors.white,
        splashColor: AppColors.primary,
        highlightColor: AppColors.primary,
        boxShadowColor: AppColors.primary,
        minWidth: double.infinity,
      ),
    ),
  );
}
