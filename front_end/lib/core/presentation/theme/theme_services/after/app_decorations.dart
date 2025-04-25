// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import '../app_colors.dart';

class AppDecorations {
  // Card Decorations
  static BoxDecoration storeCardDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 10,
        offset: Offset(0, 5),
      ),
    ],
  );

  // Gradient Overlay
  static BoxDecoration gradientOverlay = BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black,
      ],
    ),
  );

  // Chip Decoration
  static BoxDecoration chipDecoration = BoxDecoration(
    color: AppColors.secondary,
    borderRadius: BorderRadius.circular(20),
  );

  // Badge Decoration
  static BoxDecoration badgeDecoration = BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(10),
  );

  // Text Styles
  static TextStyle categoryChipLabelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  static TextStyle badgeTextStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
