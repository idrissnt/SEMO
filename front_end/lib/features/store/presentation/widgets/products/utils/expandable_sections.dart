import 'package:flutter/material.dart';

/// Build an expandable section
Widget buildExpandableSection({
  required String title,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Icon(Icons.add),
      ],
    ),
  );
}

/// Build the expandable sections (Details and Ingredients)
Widget buildExpandableSections() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Details expandable section
      buildExpandableSection(
        title: 'Details',
        onTap: () {
          // Expand details section
        },
      ),
      const SizedBox(height: 16),

      // Ingredients expandable section
      buildExpandableSection(
        title: 'Ingredients',
        onTap: () {
          // Expand ingredients section
        },
      ),
      const SizedBox(height: 16),
    ],
  );
}
