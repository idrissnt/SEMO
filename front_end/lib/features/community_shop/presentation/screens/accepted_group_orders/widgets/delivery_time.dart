import 'package:semo/core/utils/logger.dart';

final AppLogger _logger = AppLogger();

// Helper method to determine if delivery time is within current time window
bool isDeliveryTimeNow(String deliveryTime) {
  // Parse the delivery time string
  // Expected format: "Aujourd'hui, 18h-20h" or "Demain, 10h-12h"
  try {
    // Extract the time window (e.g., "18h-20h")
    final timeWindow = deliveryTime.split(', ')[1];
    final times = timeWindow.split('-');

    if (times.length != 2) return false;

    // Extract hours
    final startHour = int.tryParse(times[0].replaceAll('h', '')) ?? 0;
    final endHour = int.tryParse(times[1].replaceAll('h', '')) ?? 0;

    // Get current time
    final now = DateTime.now();
    final currentHour = now.hour;

    // Check if today or tomorrow
    final isToday = deliveryTime.toLowerCase().contains('aujourd\'hui');
    // final isTomorrow = deliveryTime.toLowerCase().contains('demain');

    if (isToday && currentHour >= startHour && currentHour < endHour) {
      return true; // Current time is within delivery window today
    }

    // For future implementation: handle tomorrow's deliveries
    return false;
  } catch (e) {
    _logger.error('Error parsing delivery time: $e');
    return false;
  }
}

// Helper method to check if delivery is upcoming (within next 30 minutes)
bool isDeliveryUpcoming(String deliveryTime) {
  try {
    // Extract the time window (e.g., "18h-20h")
    final timeWindow = deliveryTime.split(', ')[1];
    final times = timeWindow.split('-');

    if (times.length != 2) return false;

    // Extract hours
    final startHour = int.tryParse(times[0].replaceAll('h', '')) ?? 0;

    // Get current time
    final now = DateTime.now();
    final currentHour = now.hour;

    // Check if today and delivery is within 1 hour
    final isToday = deliveryTime.toLowerCase().contains('aujourd\'hui');

    if (isToday &&
        (startHour - currentHour <= 1) &&
        (startHour - currentHour > 0)) {
      return true; // Delivery is upcoming within the next hour
    }

    return false;
  } catch (e) {
    _logger.error('Error checking upcoming delivery: $e');
    return false;
  }
}
