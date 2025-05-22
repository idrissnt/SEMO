import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';

/// Build the add to cart button
Widget buildAddToCartButton({
  required CategoryProduct product,
  required int quantity,
  required VoidCallback vibrateButton,
  required BuildContext context,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: () {
        // Add to cart functionality would go here
        vibrateButton();
        Navigator.pop(
            context); // Return to previous screen after adding to cart
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        'Add $quantity to cart • \$${(product.price * quantity).toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
