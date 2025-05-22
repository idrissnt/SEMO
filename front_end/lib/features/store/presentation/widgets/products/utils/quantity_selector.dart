import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

/// Build a quantity button (+ or -)
Widget buildQuantityButton({
  required IconData icon,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(4),
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 20),
    ),
  );
}

/// Build the quantity selector
Widget buildQuantitySelector({
  required int quantity,
  required Function(int) onQuantityChanged,
  required Function() vibrateButton,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      children: [
        buildQuantityButton(
          icon: Icons.remove,
          onTap: () {
            if (quantity > 1) {
              onQuantityChanged(quantity - 1);
              vibrateButton();
            }
          },
        ),
        Container(
          width: 50,
          alignment: Alignment.center,
          child: Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        buildQuantityButton(
          icon: Icons.add,
          onTap: () {
            onQuantityChanged(quantity + 1);
            vibrateButton();
          },
        ),
      ],
    ),
  );
}

/// Provides haptic feedback when buttons are pressed
Future<void> vibrateButton() async {
  // Check if device supports vibration
  bool? hasVibrator = await Vibration.hasVibrator();
  if (hasVibrator == true) {
    Vibration.vibrate(duration: 20, amplitude: 80); // Short, light vibration
  }
}
