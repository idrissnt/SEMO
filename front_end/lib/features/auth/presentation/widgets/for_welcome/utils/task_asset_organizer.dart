import 'package:semo/features/auth/domain/entities/welcom_entity.dart';

/// Utility class for organizing task assets into categories
class TaskAssetOrganizer {
  /// Organizes task assets into categories based on their field completeness
  static Map<String, dynamic> organizeAssets(List<TaskAsset> assets) {
    // Single-pass asset categorization
    TaskAsset? titleAsset;
    List<TaskAsset> completeAssets = []; // Assets with all fields
    List<TaskAsset> partialAssets = []; // Assets with just profile info
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
          completeAssets.add(asset); // Add to complete assets list
        } else if (hasProfileImage && hasProfileTitle) {
          partialAssets.add(asset); // Add to partial assets list
        } else {
          backgroundCardAssets.add(asset);
        }
      }
    }

    // Combine lists ensuring complete assets come first (left side)
    List<TaskAsset> mainCardAssets = [...completeAssets, ...partialAssets];

    return {
      'titleAsset': titleAsset ?? (assets.isNotEmpty ? assets.first : null),
      'mainCardAssets': mainCardAssets,
      'backgroundCardAssets': backgroundCardAssets,
    };
  }
}
