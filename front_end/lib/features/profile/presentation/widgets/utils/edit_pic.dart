import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

void showImageSourceDialog(
    BuildContext context, bool hasExistingProfilePicture) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Change Profile Picture',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.photo_camera, color: AppColors.primary),
            title: const Text('Take a photo'),
            onTap: () {
              // Handle camera option
              context.pop();
              // Implement camera functionality
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: AppColors.primary),
            title: const Text('Choose from gallery'),
            onTap: () {
              // Handle gallery option
              context.pop();
              // Implement gallery functionality
            },
          ),
          if (hasExistingProfilePicture)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Remove current photo'),
              onTap: () {
                // Handle remove option
                context.pop();
                // Implement remove functionality
              },
            ),
          const SizedBox(height: 50),
        ],
      ),
    ),
  );
}
