import 'package:semo/features/auth/domain/entities/welcom_entity.dart';

/// Utility class for organizing task assets into categories
class TaskAssetOrganizer {
  /// Organizes task assets into categories based on their field completeness
  static Map<String, dynamic> organizeAssets(List<TaskAsset> assets) {
    // Single-pass asset categorization
    TaskAsset? titleAsset;
    List<TaskAsset> mainCardAssets = [];
    List<TaskAsset> backgroundCardAssets = [];

    for (var asset in assets) {
      // Check fields in a single conditional block
      bool hasTitle = asset.title.isNotEmpty;
      bool hasTaskImage = asset.taskImage.isNotEmpty;
      bool hasProfileImage = asset.taskerProfileImageUrl.isNotEmpty;
      bool hasProfileTitle = asset.taskerProfileTitle.isNotEmpty;

      if (hasTaskImage) {
        if (hasTitle && hasProfileImage && hasProfileTitle) {
          titleAsset ??= asset;
          mainCardAssets.add(asset);
        } else if (hasProfileImage && hasProfileTitle) {
          mainCardAssets.add(asset);
        } else {
          backgroundCardAssets.add(asset);
        }
      }
    }

    return {
      'titleAsset': titleAsset ?? (assets.isNotEmpty ? assets.first : null),
      'mainCardAssets': mainCardAssets,
      'backgroundCardAssets': backgroundCardAssets,
    };
  }
}
