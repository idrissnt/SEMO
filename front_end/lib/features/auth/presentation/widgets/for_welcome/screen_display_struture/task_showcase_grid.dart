import 'package:flutter/material.dart';

import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/core/utils/logger.dart';

import 'package:semo/features/auth/presentation/widgets/for_welcome/components/task/task_card_layout.dart';
import 'package:semo/features/auth/presentation/widgets/for_welcome/components/shared/showcase_title.dart';
import 'package:semo/features/auth/presentation/widgets/for_welcome/components/task/task_content_builder.dart';
import 'package:semo/features/auth/presentation/widgets/for_welcome/screen_display_struture/utils/base_store_task_showcase.dart';

import 'package:semo/features/auth/domain/entities/welcom_entity.dart';

final AppLogger logger = AppLogger();

/// Builds a task showcase card using the staggered grid layout
Widget buildTaskCard(BuildContext context, List<TaskAsset> taskAssets) {
  return Card(
    color: AppColors.secondary,
    elevation: 4,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xxl)),
    child: Builder(builder: (context) {
      if (taskAssets.isEmpty) {
        // Handle empty task list case
        logger.info('Task assets loaded but empty');
        return const Center(
          child: Text('Task assets coming soon...',
              style: TextStyle(color: AppColors.textPrimaryColor)),
        );
      }

      // Process task data using the existing builder
      final data = TaskContentBuilder.build(context, taskAssets);

      return TaskCardShowcaseGrid(
        titleText: data['titleText'],
        mainCards: data['mainCards'],
        backgroundImages: data['backgroundImages'],
      );
    }),
  );
}

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
    return BaseShowcase(
      padding: EdgeInsets.symmetric(
        vertical: AppDimensionsHeight.xl,
        horizontal: AppDimensionsWidth.small,
      ),
      // Title section
      titleSection: showcaseTitle(titleText, AppColors.textPrimaryColor),
      // Content section
      contentSection: CardLayout(
        mainCards: mainCards,
        backgroundImages: backgroundImages,
      ),
    );
  }
}
