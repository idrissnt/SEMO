// Build the appropriate delivery action buttons based on time
import 'package:flutter/material.dart';
import 'package:semo/features/community_shop/domain/enums/order_state.dart';
// import 'package:semo/features/community_shop/presentation/screens/accepted_group_orders/widgets/delivery_time.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/utils/logger.dart';

final AppLogger _logger = AppLogger();

Widget buildDeliveryActionButtons(
    {required CommunityOrder order,
    required Function(CommunityOrder) onOrderStateChanged,
    required Function(CommunityOrder) onStartOrder}) {
  // final deliveryTime = order.deliveryTime;

  // When database format changes, you would parse ISO dates here
  // Example with ISO format:
  // final deliveryStart = DateTime.parse(orders.first.deliveryTimeStart);
  // final deliveryEnd = DateTime.parse(orders.first.deliveryTimeEnd);
  // final now = DateTime.now();
  // final isNow = now.isAfter(deliveryStart) && now.isBefore(deliveryEnd);
  // final isUpcoming = now.isBefore(deliveryStart) &&
  //    deliveryStart.difference(now).inMinutes <= 60;

  // final isNow = isDeliveryTimeNow(deliveryTime);
  // final isUpcoming = isDeliveryUpcoming(deliveryTime);

  // Display different buttons based on the current state of the order
  switch (order.state) {
    case OrderState.scheduled:
      // For programmed orders, show only "Commencer" button
      return _buildActionButtons(
        onPress: () {
          _logger.info('Starting programmed delivery');
          // Update order state to inProgress
          final updatedOrder = order.copyWith(state: OrderState.inProgress);
          onOrderStateChanged(updatedOrder);
          onStartOrder(updatedOrder);
        },
        text: 'Je commence maintenant',
        color: AppColors.primary,
        textColor: Colors.white,
      );

    case OrderState.inProgress:
      // For orders in progress, show a disabled button
      return _buildActionButtons(
        onPress: () {
          _logger.info('Starting programmed delivery');
          // Update order state to inProgress
          final updatedOrder = order.copyWith(state: OrderState.inProgress);
          onOrderStateChanged(updatedOrder);
          onStartOrder(updatedOrder);
        },
        // onPress: null, // null means the button will be disabled

        text: 'Je continue',
        color: Colors.grey.shade200,
        textColor: Colors.black,
      );
  }
}

Widget _buildActionButtons(
    {VoidCallback? onPress,
    required String text,
    required Color color,
    required Color textColor}) {
  return Row(
    children: [
      Expanded(
        child: ElevatedButton(
          onPressed: onPress,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ],
  );
}
