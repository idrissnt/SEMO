import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/profile/presentation/widgets/settings_section.dart';
import 'package:semo/features/profile/presentation/widgets/settings_tile.dart';

/// Tab for grocery-related settings and history
class GroceryTab extends StatefulWidget {
  const GroceryTab({Key? key}) : super(key: key);

  @override
  State<GroceryTab> createState() => _GroceryTabState();
}

class _GroceryTabState extends State<GroceryTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            title: 'Mode acheteur',
            children: [
              SettingsTile(
                icon: const Icon(Icons.shopping_basket, color: Colors.white),
                iconContainerColor: Colors.green,
                title: 'Commandes',
                subtitle: 'En cours, programmées, livrées',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 16),

          // My Deliveries
          SettingsSection(
            title: 'Mode livreur',
            children: [
              SettingsTile(
                icon: const Icon(Icons.local_shipping, color: Colors.white),
                iconContainerColor: Colors.red,
                title: 'Commandes',
                subtitle: 'En cours, programmées, livrées',
                onTap: () {},
              ),
              SettingsTile(
                icon: const Icon(Icons.euro, color: Colors.white),
                iconContainerColor: Colors.orange,
                title: 'Remunération',
                subtitle: 'Mes revenus',
                onTap: () {},
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
            'Statistiques de mes commandes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                  '0',
                  'Mode acheteur',
                  const Icon(Icons.shopping_basket, color: Colors.white),
                  Colors.green),
              _buildStatItem(
                  '0',
                  'Mode livreur',
                  const Icon(Icons.local_shipping, color: Colors.white),
                  Colors.red),
              _buildStatItem('0', 'Note reçue',
                  const Icon(Icons.star, color: Colors.white), Colors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, Widget icon, Color backgroundColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: icon,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimaryColor,
          ),
        ),
      ],
    );
  }
}
