import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

Widget note(BuildContext context, bool isExpanded, String title,
    String subtitle, Widget icon, Color backgroundColor) {
  return Row(
    children: [
      // receipt icon
      Container(
        padding: const EdgeInsets.all(6),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: icon,
      ),
      const SizedBox(width: 8),
      // Title and subtitle
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                const Spacer(),
              ],
            ),
            if (!isExpanded) const SizedBox(height: 2),
            if (!isExpanded)
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
      Icon(
        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
        color: Colors.grey,
      ),
    ],
  );
}
