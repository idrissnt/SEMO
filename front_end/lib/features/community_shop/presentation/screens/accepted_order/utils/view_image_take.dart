import 'dart:io';
import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

Widget viewImageTake({
  required File image,
  required BuildContext context,
  required Function onRetake,
  required Function onConfirm,
}) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Stack(
      children: [
        // Image takes the full screen
        Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: Image.file(
              image,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        // Bottom controls
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildButtonRetake(
                  action: onRetake,
                  context: context,
                  text: 'Reprendre',
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  backgroundColor: AppColors.thirdColor),
              const SizedBox(width: 16),
              buildButtonRetake(
                  action: onConfirm,
                  context: context,
                  text: 'Enregistrer',
                  icon: const Icon(Icons.check, color: Colors.white),
                  backgroundColor: AppColors.primary),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildButtonRetake(
    {required BuildContext context,
    required String text,
    required Icon icon,
    required Function action,
    required Color backgroundColor}) {
  return ElevatedButton.icon(
    onPressed: () {
      // Retake photo
      Navigator.of(context).pop();
      action();
    },
    icon: icon,
    label: Text(text, style: const TextStyle(fontSize: 18)),
    style: ElevatedButton.styleFrom(
      fixedSize: const Size(150, 55),
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}
