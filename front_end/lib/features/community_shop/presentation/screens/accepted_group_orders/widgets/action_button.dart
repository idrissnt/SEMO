// Build the appropriate delivery action buttons based on time
import 'package:flutter/material.dart';
import 'package:semo/features/community_shop/domain/enums/order_state.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_group_orders/widgets/delivery_time.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/utils/logger.dart';

final AppLogger _logger = AppLogger();

Widget buildDeliveryActionButtons({required CommunityOrder order, required Function(CommunityOrder) onOrderStateChanged}) {
  final deliveryTime = order.deliveryTime;

  // When database format changes, you would parse ISO dates here
  // Example with ISO format:
  // final deliveryStart = DateTime.parse(orders.first.deliveryTimeStart);
  // final deliveryEnd = DateTime.parse(orders.first.deliveryTimeEnd);
  // final now = DateTime.now();
  // final isNow = now.isAfter(deliveryStart) && now.isBefore(deliveryEnd);
  // final isUpcoming = now.isBefore(deliveryStart) &&
  //    deliveryStart.difference(now).inMinutes <= 60;

  final isNow = isDeliveryTimeNow(deliveryTime);
  final isUpcoming = isDeliveryUpcoming(deliveryTime);

  // Display different buttons based on the current state of the order
  switch (order.state) {
    case OrderState.enAttente:
      if (isNow) {
        // Delivery time is now, show only "Commencer" button
        return _buildActionButtons(
          () {
            _logger.info('Starting delivery now');
            // Update order state to enCours
            final updatedOrder = order.copyWith(state: OrderState.enCours);
            onOrderStateChanged(updatedOrder);
          },
          'Commencer',
          AppColors.primary,
          Colors.white,
        );
      } else if (!isUpcoming) {
        // Delivery is upcoming, show both buttons
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _buildActionButtons(
                () {
                  _logger.info('Scheduling delivery');
                  // Update order state to programmer
                  final updatedOrder = order.copyWith(state: OrderState.programmer);
                  onOrderStateChanged(updatedOrder);
                },
                'Programmer',
                Colors.grey.shade200,
                Colors.black87,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButtons(
                () {
                  _logger.info('Starting delivery early');
                  // Update order state to enCours
                  final updatedOrder = order.copyWith(state: OrderState.enCours);
                  onOrderStateChanged(updatedOrder);
                },
                'Commencer',
                AppColors.primary,
                Colors.white,
              ),
            ),
          ],
        );
      } else {
        // Delivery is far in the future, show only "Programmer" button
        return _buildActionButtons(
          () {
            _logger.info('Scheduling future delivery');
            // Update order state to programmer
            final updatedOrder = order.copyWith(state: OrderState.programmer);
            onOrderStateChanged(updatedOrder);
          },
          'Programmer',
          Colors.grey.shade200,
          Colors.black87,
        );
      }
      
    case OrderState.programmer:
      // For programmed orders, show only "Commencer" button
      return _buildActionButtons(
        () {
          _logger.info('Starting programmed delivery');
          // Update order state to enCours
          final updatedOrder = order.copyWith(state: OrderState.enCours);
          onOrderStateChanged(updatedOrder);
        },
        'Commencer',
        AppColors.primary,
        Colors.white,
      );
      
    case OrderState.enCours:
      // For orders in progress, show a disabled button
      return _buildActionButtons(
        null, // null means the button will be disabled
        'En cours de livraison',
        Colors.grey.shade300,
        Colors.grey.shade700,
      );
  }
}

Widget _buildActionButtons(
    VoidCallback? onPress, String text, Color color, Color textColor) {
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
