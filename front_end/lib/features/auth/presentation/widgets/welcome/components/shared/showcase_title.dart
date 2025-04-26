import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Creates a standardized title text for showcase cards
Widget showcaseTitle(String text, Color color) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 28.sp, // Using the same size as in cardTitleText
      fontWeight: FontWeight.w900,
      color: color,
    ),
  );
}

/// Creates a multi-line title with different styles for each line
Widget multiLineShowcaseTitle(List<Map<String, dynamic>> titleLines) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: titleLines.map((lineData) {
      return showcaseTitle(
        lineData['text'] as String,
        lineData['color'] as Color,
      );
    }).toList(),
  );
}
