import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/profile/presentation/widgets/settings_section.dart';
import 'package:semo/features/profile/presentation/widgets/settings_tile.dart';
import 'package:semo/features/profile/routes/profile_routes_const.dart';

/// Tab for grocery-related settings and history
class GroceryTab extends StatelessWidget {
  const GroceryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grocery Statistics
          _buildGroceryStatistics(),

          const SizedBox(height: 24),

          // My Orders
          const SettingsSection(
            title: 'My Orders',
            children: [
              SettingsTile(
                icon: Icons.shopping_bag_outlined,
                title: 'Active Orders',
                subtitle: 'Orders currently in progress',
                routeName: ProfileRouteNames.groceryOrders,
              ),
              SettingsTile(
                icon: Icons.check_circle_outline,
                title: 'Completed Orders',
                subtitle: 'Orders that have been delivered',
                routeName: ProfileRouteNames.groceryOrders,
              ),
              SettingsTile(
                icon: Icons.history_outlined,
                title: 'Order History',
                subtitle: 'All your past grocery orders',
                routeName: ProfileRouteNames.groceryOrders,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // My Deliveries
          const SettingsSection(
            title: 'My Deliveries',
            children: [
              SettingsTile(
                icon: Icons.delivery_dining_outlined,
                title: 'Current Deliveries',
                subtitle: 'Deliveries you\'re currently handling',
                routeName: ProfileRouteNames.groceryDeliveries,
              ),
              SettingsTile(
                icon: Icons.check_circle_outline,
                title: 'Completed Deliveries',
                subtitle: 'Deliveries you\'ve finished',
                routeName: ProfileRouteNames.groceryDeliveries,
              ),
              SettingsTile(
                icon: Icons.history_outlined,
                title: 'Delivery History',
                subtitle: 'All deliveries you\'ve made',
                routeName: ProfileRouteNames.groceryDeliveries,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Favorites & Preferences
          const SettingsSection(
            title: 'Favorites & Preferences',
            children: [
              SettingsTile(
                icon: Icons.favorite_outline,
                title: 'Favorite Stores',
                subtitle: 'Stores you frequently order from',
                routeName: ProfileRouteNames.favoriteStores,
              ),
              SettingsTile(
                icon: Icons.shopping_cart_outlined,
                title: 'Favorite Products',
                subtitle: 'Products you frequently order',
                routeName: ProfileRouteNames.favoriteProducts,
              ),
              SettingsTile(
                icon: Icons.directions_car_outlined,
                title: 'Delivery Preferences',
                subtitle: 'Vehicle details, availability, areas',
                routeName: ProfileRouteNames.deliveryPreferences,
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGroceryStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grocery Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('24', 'Orders', Icons.shopping_bag_outlined),
              _buildStatItem(
                  '18', 'Deliveries', Icons.delivery_dining_outlined),
              _buildStatItem('4.9', 'Rating', Icons.star_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
