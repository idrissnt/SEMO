import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';

/// Service class that handles filtering of community orders
class OrderFilterService {
  /// Filter orders based on the provided filter values
  static List<CommunityOrder> filterOrders(
    List<CommunityOrder> allOrders,
    Map<String, dynamic> filters,
  ) {
    if (filters.isEmpty) {
      return List.from(allOrders);
    }

    return allOrders.where((order) {
      // Check all markets filter (default)
      if (filters['all_markets'] == true) {
        // Apply other filters but don't filter by store
      }
      // Check specific market filter
      else if (filters.containsKey('one_market')) {
        var storeData = filters['one_market'];
        String selectedStore;

        if (storeData is Map<String, dynamic> &&
            storeData.containsKey('name')) {
          selectedStore = storeData['name'];
        } else if (storeData is String) {
          selectedStore = storeData; // For backward compatibility
        } else {
          return false; // Invalid store data
        }

        if (order.storeName != selectedStore) {
          return false; // Skip if not from selected store
        }
      }

      // Check urgent filter
      if (filters['urgent'] == true && !order.isUrgent) {
        return false;
      }

      // Check distance filter
      if (filters.containsKey('distance')) {
        double maxDistance = filters['distance'];
        if (order.distanceKm > maxDistance) {
          return false;
        }
      }

      // Check scheduled filter
      if (filters.containsKey('scheduled')) {
        String schedule = filters['scheduled'];
        // This would typically check the delivery time against the schedule
        // For demo, we'll just check if it contains the schedule text
        if (!order.deliveryTime.contains(schedule)) {
          return false;
        }
      }

      // Check high reward filter
      if (filters['high_reward'] == true && order.reward < 4.0) {
        return false;
      }

      return true; // Include order if it passes all filters
    }).toList();
  }
}
