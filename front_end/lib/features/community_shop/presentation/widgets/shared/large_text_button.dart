import 'package:flutter/material.dart';

Widget buildLargeTextButton(BuildContext context,
    {required VoidCallback onTap,
    int count = 0,
    required String text,
    required Color iconColor,
    required Color textColor,
    required bool showCount}) {
  return Stack(
    children: [
      IconButton(
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(0),
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        onPressed: onTap,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(text,
              style: TextStyle(
                  color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
        ),
      ),
      if (showCount)
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Text(count.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ),
        ),
    ],
  );
}
