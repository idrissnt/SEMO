import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

class CartBar extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double minimumOrderValue;
  final double progressToFreeDelivery;
  final VoidCallback onCartTap;
  final int itemCount;

  const CartBar({
    Key? key,
    required this.subtotal,
    required this.deliveryFee,
    required this.minimumOrderValue,
    required this.progressToFreeDelivery,
    required this.onCartTap,
    required this.itemCount,
  }) : super(key: key);

  bool get _qualifiesForFreeDelivery => subtotal >= minimumOrderValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Delivery fee and progress information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _qualifiesForFreeDelivery
                      ? 'Free delivery'
                      : '\$${deliveryFee.toStringAsFixed(2)} delivery fee, spend \$${(minimumOrderValue - subtotal).toStringAsFixed(2)} more',
                  style: const TextStyle(
                    color: AppColors.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Progress bar
                Container(
                  height: 4,
                  margin: const EdgeInsets.only(top: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progressToFreeDelivery,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cart button
          GestureDetector(
            onTap: onCartTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  itemCount > 0 ? 'Cart • $itemCount' : 'Cart',
                  style: const TextStyle(
                    color: AppColors.textSecondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
