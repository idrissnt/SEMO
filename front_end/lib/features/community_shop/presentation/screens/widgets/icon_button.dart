// Build button
import 'package:flutter/material.dart';

Widget buildIconButton(IconData icon, Color color, Color backgroundColor) {
  return Container(
    decoration: BoxDecoration(
      color: backgroundColor,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(icon, size: 24, color: color),
    ),
  );
}
