import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

/// Builds the urgent tag
Widget buildUrgentTag() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.red.shade200),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.priority_high,
          size: 14,
          color: Colors.red,
        ),
        SizedBox(width: 4),
        Text(
          'Urgent',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

Widget buildCard({required String storeName, required Widget child}) {
  return Column(
    children: [
      GestureDetector(
        onTap: () {},
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                storeName.toLowerCase().contains('lec')
                    ? Colors.blue.withValues(alpha: 0.4)
                    : storeName.toLowerCase().contains('car')
                        ? const Color.fromARGB(255, 249, 47, 47)
                            .withValues(alpha: 0.4)
                        : const Color.fromARGB(255, 255, 196, 0)
                            .withValues(alpha: 0.4), // Top (blue)

                storeName.toLowerCase().contains('lec')
                    ? Colors.blue.withValues(alpha: 0.4)
                    : storeName.toLowerCase().contains('car')
                        ? const Color.fromARGB(255, 249, 47, 47)
                            .withValues(alpha: 0.4)
                        : const Color.fromARGB(255, 255, 196, 0)
                            .withValues(alpha: 0.4), // Top-right (red)

                Colors.white, // Right (white)
                Colors.white, // Bottom-right (white)
              ],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(20), // Slightly larger radius
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    ],
  );
}

/// Builds an information row with an icon and text
Widget buildInfoRow(IconData icon, String text, Color iconColor) {
  return Row(
    children: [
      Icon(
        icon,
        size: 16,
        color: iconColor,
      ),
      const SizedBox(width: 8),
      Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
