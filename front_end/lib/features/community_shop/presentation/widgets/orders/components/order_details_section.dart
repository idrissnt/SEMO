import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';

/// Widget that displays order details information
class OrderDetailsSection extends StatelessWidget {
  final CommunityOrder order;

  const OrderDetailsSection({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textPrimaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            Icons.shopping_basket,
            '${order.totalItems} articles',
            Colors.green,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.euro,
            '${order.totalPrice.toStringAsFixed(2)}€',
            Colors.red,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.schedule,
            order.deliveryTime,
            Colors.blue,
          ),
          const SizedBox(height: 8),
          if (order.isUrgent) buildUrgentTag(),
        ],
      ),
    );
  }

  /// Builds an information row with an icon and text
  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textPrimaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Builds the urgent tag
  Widget buildUrgentTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.priority_high,
            size: 14,
            color: Colors.red,
          ),
          SizedBox(width: 4),
          Text(
            'Urgent',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
