import 'package:flutter/material.dart';

Widget buildSection(List<Widget> children) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(children: children),
  );
}

Widget buildListItem({
  required String title,
  required IconData icon,
  required bool isVerified,
  required VoidCallback onTap,
  required Color iconColor,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (isVerified)
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Icon(Icons.edit, color: Colors.black),
              ],
            )
          else
            const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    ),
  );
}
