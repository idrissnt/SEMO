import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';

/// Widget that builds the footer section of a community order card
/// Shows reward and action button
class OrderCardFooter extends StatelessWidget {
  final CommunityOrder order;
  final VoidCallback? onPress;

  const OrderCardFooter({
    Key? key,
    required this.order,
    this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Reward
          Expanded(
            flex: 5,
            child: buildReward(),
          ),
          const Spacer(),
          // Accept button
          Expanded(
            flex: 6,
            child: ElevatedButton(
              onPressed: onPress,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
              child: Text(
                'Plus de détails',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppFontSize.xMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReward() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber),
      ),
      child: Row(
        children: [
          Icon(FontAwesomeIcons.sackDollar,
              size: AppIconSize.medium, color: Colors.amber),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '${order.reward.toStringAsFixed(1)}€ pour vous',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: AppFontSize.small,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
