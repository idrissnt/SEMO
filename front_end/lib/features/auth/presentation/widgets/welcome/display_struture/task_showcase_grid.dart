import 'package:flutter/material.dart';

import 'package:semo/core/presentation/theme/theme_services/app_colors.dart';
import 'package:semo/core/presentation/theme/theme_services/app_dimensions.dart';

import 'package:semo/features/auth/presentation/widgets/welcome/components/auth_buttons.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/components/task/task_card_layout.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/styles/company_and_store_theme.dart';

/// This widget creates a visually appealing showcase of products using a staggered grid layout,
/// similar to a masonry grid, with a text caption at the bottom.
class TaskCardShowcaseGrid extends StatelessWidget {
  // Core properties for task card display
  final List<Map<String, String>> mainCards;
  final List<String> backgroundImages;
  final String titleText;

  const TaskCardShowcaseGrid({
    Key? key,
    required this.titleText,
    required this.mainCards,
    required this.backgroundImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: AppDimensionsHeight.xl,
          horizontal: AppDimensionsWidth.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title text
          cardTitleText(titleText, AppColors.textPrimaryColor),

          // Task cards display
          CardLayout(
            mainCards: mainCards,
            backgroundImages: backgroundImages,
          ),

          // Auth buttons
          const AuthButtons(),
        ],
      ),
    );
  }
}
