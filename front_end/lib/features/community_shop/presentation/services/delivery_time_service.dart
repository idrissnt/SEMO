import 'package:flutter/material.dart';
import 'package:semo/core/presentation/widgets/bottom_sheets/reusable_bottom_sheet.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/presentation/widgets/calendar/delivery_time_picker.dart';
import 'package:semo/features/community_shop/presentation/services/order_interaction_service.dart';

/// Service to handle delivery time selection and order starting
class DeliveryTimeService {
  /// Shows a bottom sheet with a calendar to select delivery time
  /// and then starts the order with the selected time
  void showDeliveryTimePicker({
    required BuildContext context,
    required CommunityOrder order,
  }) {
    showReusableBottomSheet(
      context: context,
      contentBuilder: (scrollController) => DeliveryTimePicker(
        onTimeSelected: (selectedDateTime) {
          // Here you can save the selected time to the order or pass it along
          // For now, we'll just start the order after selection
          OrderInteractionService().handleDeliveryTimeSelection(
            context, order,
            // we can pass the selected time as an additional parameter if needed
            // selectedTime: selectedDateTime,
          );
        },
      ),
    );
  }
}
