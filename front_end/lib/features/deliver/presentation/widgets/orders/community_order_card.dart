import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/deliver/presentation/test_data/community_orders.dart';
import 'package:semo/features/deliver/presentation/widgets/cart/transparent_cart.dart';

/// A card widget that displays a community shopping order
/// with product images, customer information, and action buttons.
class CommunityOrderCard extends StatelessWidget {
  /// The community order to display
  final CommunityOrder order;

  /// Callback when the card is tapped
  final VoidCallback onTap;

  /// Callback when the user accepts the order
  final VoidCallback onAccept;

  const CommunityOrderCard({
    Key? key,
    required this.order,
    required this.onTap,
    required this.onAccept,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The order card
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  order.storeName.contains('Ca')
                      ? Colors.blue.withValues(alpha: 0.5)
                      : order.storeName.contains('Lec')
                          ? Colors.orange.withValues(alpha: 0.5)
                          : const Color.fromARGB(
                              255, 21, 104, 103), // Top (blue)
                  order.storeName.contains('Ca')
                      ? Colors.red.withValues(alpha: 0.5)
                      : order.storeName.contains('Lec')
                          ? Colors.blue.withValues(alpha: 0.5)
                          : const Color.fromARGB(
                              255, 165, 122, 12), // Top-right (red)
                  Colors.white, // Right (yellow)
                  Colors.white, // Bottom-right (gr
                  // Colors.white, // Bottom-right (gr
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(20), // Slightly larger radius
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(),
                _buildOrderContent(),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the header with customer info and distance
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Store logo and name
          Expanded(
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
                          image: NetworkImage(order.storeLogoUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.storeName,
                      style: const TextStyle(
                        color: AppColors.textPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Distance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.place,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 2),
                Text(
                  '${order.distanceKm.toStringAsFixed(1)} km de vous',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main content with transparent cart and order details
  Widget _buildOrderContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Transparent cart with products
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                if (order.productImageUrls.length > 1)
                  Positioned(
                    top: 0, // Position in the middle of the basket
                    left: 30,
                    child: Transform.rotate(
                        angle: 0.2, // Slight tilt to the right
                        child: _buildProductImage(
                            order.productImageUrls[0], 50, 70)),
                  ),
                if (order.productImageUrls.isNotEmpty)
                  Positioned(
                    top: 5,
                    left: 45,
                    child: Transform.rotate(
                      angle: -0.3, // Tilt to the left
                      child:
                          _buildProductImage(order.productImageUrls[1], 50, 70),
                    ),
                  ),
                // If there are more products, show a +N indicator
                if (order.productImageUrls.length > 2)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.storeCardBorderColor,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 2,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '+${order.productImageUrls.length - 2}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                const TransparentCart(
                  size: 120,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          // Order details
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 0),
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
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.euro,
                    '${order.totalPrice.toStringAsFixed(2)}€',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.schedule,
                    order.deliveryTime,
                  ),
                  const SizedBox(height: 8),
                  if (order.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a row with an icon and text for order details
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textPrimaryColor,
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

  /// Builds the footer with reward and action button
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Reward
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textPrimaryColor),
            ),
            child: Row(
              children: [
                const Icon(
                  FontAwesomeIcons.sackDollar,
                  size: 16,
                  color: Colors.black,
                ),
                const SizedBox(width: 4),
                Text(
                  '${order.reward.toStringAsFixed(1)}€ pour vous',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Accept button
          ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.primary),
              ),
              // padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text(
              'Je prends',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imageUrl, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 2,
            spreadRadius: 0.5,
            offset: const Offset(0, 1),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
