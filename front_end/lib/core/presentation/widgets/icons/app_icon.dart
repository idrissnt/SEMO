import 'package:flutter/material.dart';

Widget appIcon(
    {required Widget icon,
    required Color iconContainerColor,
    double? height,
    double? width,
    double? borderWidth}) {
  return Container(
    padding: const EdgeInsets.all(6),
    width: width ?? 40,
    height: height ?? 40,
    decoration: BoxDecoration(
      color: iconContainerColor,
      borderRadius: BorderRadius.circular(8),
      border: borderWidth != null
          ? Border.all(color: Colors.black, width: borderWidth)
          : null,
    ),
    child: icon,
  );
}
