import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

/// A reusable settings tile widget for profile settings
class SettingsTile extends StatelessWidget {
  final Widget icon;
  final Color iconContainerColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isCompleted;

  const SettingsTile({
    Key? key,
    required this.icon,
    required this.iconContainerColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isCompleted = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Leading icon
                Container(
                  padding: const EdgeInsets.all(6),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconContainerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: icon,
                ),
                const SizedBox(width: 16),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (!isCompleted)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              height: 25,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'à compléter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryColor,
                ),
              ),
            ),
          )
      ],
    );
  }
}
