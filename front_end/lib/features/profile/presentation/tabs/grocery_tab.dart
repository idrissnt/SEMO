import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_icons.dart';
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
          SettingsSection(
            title: 'My Orders',
            children: [
              SettingsTile(
                icon: AppIcons.shoppingBag(size: 24, color: Colors.orange),
                title: 'Active Orders',
                subtitle: 'Orders currently in progress',
                routeName: ProfileRouteNames.groceryOrders,
              ),
              SettingsTile(
                icon: AppIcons.checkCircle(size: 24, color: Colors.green),
                title: 'Completed Orders',
                subtitle: 'Orders that have been delivered',
                routeName: ProfileRouteNames.groceryOrders,
              ),
              SettingsTile(
                icon: AppIcons.history(size: 24, color: Colors.grey[700]),
                title: 'Order History',
                subtitle: 'All your past grocery orders',
                routeName: ProfileRouteNames.groceryOrders,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // My Deliveries
          SettingsSection(
            title: 'My Deliveries',
            children: [
              SettingsTile(
                icon: AppIcons.delivery(size: 24, color: Colors.purple),
                title: 'Current Deliveries',
                subtitle: 'Deliveries you\'re currently handling',
                routeName: ProfileRouteNames.groceryDeliveries,
              ),
              SettingsTile(
                icon: AppIcons.checkCircle(size: 24, color: Colors.green),
                title: 'Completed Deliveries',
                subtitle: 'Deliveries you\'ve finished',
                routeName: ProfileRouteNames.groceryDeliveries,
              ),
              SettingsTile(
                icon: AppIcons.history(size: 24, color: Colors.grey[700]),
                title: 'Delivery History',
                subtitle: 'All deliveries you\'ve made',
                routeName: ProfileRouteNames.groceryDeliveries,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Favorites & Preferences
          SettingsSection(
            title: 'Favorites & Preferences',
            children: [
              SettingsTile(
                icon: AppIcons.favorite(size: 24, color: Colors.red),
                title: 'Favorite Stores',
                subtitle: 'Stores you frequently order from',
                routeName: ProfileRouteNames.favoriteStores,
              ),
              SettingsTile(
                icon: AppIcons.shoppingCart(size: 24, color: Colors.orange),
                title: 'Favorite Products',
                subtitle: 'Products you frequently order',
                routeName: ProfileRouteNames.favoriteProducts,
              ),
              SettingsTile(
                icon: AppIcons.car(size: 24, color: Colors.blue),
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
              _buildStatItem('24', 'Orders',
                  AppIcons.shoppingBag(size: 24, color: Colors.white)),
              _buildStatItem('18', 'Deliveries',
                  AppIcons.delivery(size: 24, color: Colors.white)),
              _buildStatItem('4.9', 'Rating',
                  AppIcons.star(size: 24, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Widget icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: icon,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
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
