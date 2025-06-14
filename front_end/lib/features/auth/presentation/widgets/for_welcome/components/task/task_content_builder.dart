import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:semo/core/utils/logger.dart';

import 'package:semo/features/auth/domain/entities/welcom_entity.dart';

import 'package:semo/features/auth/presentation/widgets/for_welcome/styles/task_card_theme.dart';
import 'package:semo/features/auth/presentation/widgets/for_welcome/utils/task_asset_organizer.dart';

/// Logger instance for the task content builder
final AppLogger logger = AppLogger();

/// Builds content when task assets are loaded
class TaskContentBuilder {
  /// Builds the task asset content for the product showcase grid
  static Map<String, dynamic> build(
      BuildContext context, List<TaskAsset> taskAssets) {
    // Log summary of task assets for debugging
    logger.info('Processing ${taskAssets.length} task assets');

    // Only log detailed asset info in debug mode
    if (kDebugMode) {
      for (int i = 0; i < taskAssets.length; i++) {
        final asset = taskAssets[i];
        logger.info(
            'Asset $i - title: ${asset.title}, hasImage: ${asset.taskImage.isNotEmpty}');
      }
    }

    // Organize assets by their purpose
    final organizedAssets = TaskAssetOrganizer.organizeAssets(taskAssets);
    final titleAsset = organizedAssets['titleAsset'] as TaskAsset?;
    final mainCardAssets = organizedAssets['mainCardAssets'] as List<TaskAsset>;
    final backgroundCardAssets =
        organizedAssets['backgroundCardAssets'] as List<TaskAsset>;

    // Log the title asset for debugging
    logger.info('Title asset: ${titleAsset?.title}');

    // Prepare the main card assets
    final List<Map<String, String>> mainCards = [];

    // Process available main card assets (up to 2)
    for (var asset in mainCardAssets.take(2)) {
      mainCards.add({
        'mainImage': asset.taskImage,
        'profileImage': asset.taskerProfileImageUrl,
        'profileTitle': asset.taskerProfileTitle,
      });
    }

    // Log summary of main cards
    logger.info('Main cards count: ${mainCards.length}');

    // Prepare the background card assets with full URLs
    final List<String> backgroundImages =
        backgroundCardAssets.take(2).map((asset) => asset.taskImage).toList();

    // Log background images for debugging
    logger.info('Background images: $backgroundImages');

    // Fill in missing cards with defaults if needed
    while (mainCards.length < 2) {
      // Create default card data with empty image URLs
      Map<String, String> defaultCard = DefaultTaskCardAssets.createCardData();

      // Add position-specific title if needed
      defaultCard['profileTitle'] =
          '${DefaultTaskCardAssets.defaultTitle} ${mainCards.length + 1}';
      mainCards.add(defaultCard);
    }

    while (backgroundImages.length < 2) {
      backgroundImages.add(DefaultTaskCardAssets.createBackgroundImage());
    }

    logger.info('Main cards: $mainCards');
    logger.info('Background images: $backgroundImages');

    // Use the existing ProductShowcaseGrid but with our organized data

    return {
      'titleText': titleAsset?.title ?? 'Task Showcase',
      'mainCards': mainCards,
      'backgroundImages': backgroundImages,
    };
  }
}
