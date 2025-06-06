import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/widgets/bottom_sheets/reusable_bottom_sheet.dart';
import 'package:semo/features/community_shop/presentation/screens/shopper_delivery_screen/utils/address_raw.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/presentation/widgets/orders/utils/show_dialog.dart';

/// Widget that builds the header section of a community order card
/// Shows store logo, name and distance information
class OrderCardHeader extends StatefulWidget {
  final CommunityOrder order;
  final VoidCallback onTap;
  final bool? isSelected;

  /// Callback when user selects to start the order from popup menu
  final VoidCallback? onStartOrder;

  /// Callback when user selects to book the order from popup menu
  final VoidCallback? onBookOrder;

  const OrderCardHeader({
    Key? key,
    required this.order,
    required this.onTap,
    this.isSelected,
    this.onStartOrder,
    this.onBookOrder,
  }) : super(key: key);

  @override
  State<OrderCardHeader> createState() => _OrderCardHeaderState();
}

class _OrderCardHeaderState extends State<OrderCardHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Store logo and name
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(widget.order.storeLogoUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.order.storeName,
                      style: const TextStyle(
                        color: AppColors.textPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                buildAddressRow(
                  widget.order.storeAddress,
                  context,
                ),
              ],
            ),
          ),
          // Distance and more button
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Client :',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.place,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${widget.order.distanceKm.toStringAsFixed(1)} km de vous',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // More button with modal dialog
                IconButton(
                  onPressed: () {
                    // Show modal dialog with action buttons using the utility function

                    showReusableBottomSheet(
                      context: context,
                      contentBuilder: (scrollController) =>
                          showOrderActionBottomSheet(
                        context: context,
                        order: widget.order,
                      ),
                    );
                  },
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                  ),
                  icon: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Icon(Icons.more_vert,
                          size: 20, color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
