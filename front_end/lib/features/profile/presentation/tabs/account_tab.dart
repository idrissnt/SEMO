import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/profile/presentation/widgets/settings_section.dart';
import 'package:semo/features/profile/presentation/widgets/settings_tile.dart';

/// Tab for account-related settings
class AccountTab extends StatelessWidget {
  const AccountTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Settings
          const SettingsSection(
            title: 'Account',
            children: [
              SettingsTile(
                icon: Icons.person_outline,
                title: 'Personal Information',
                subtitle: 'Name, email, phone number',
                route: '/profile/personal-info',
              ),
              SettingsTile(
                icon: Icons.lock_outline,
                title: 'Security',
                subtitle: 'Password, verification, login activity',
                route: '/profile/security',
              ),
              SettingsTile(
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                subtitle: 'Credit cards, bank accounts',
                route: '/profile/payment-methods',
              ),
              SettingsTile(
                icon: Icons.location_on_outlined,
                title: 'Addresses',
                subtitle: 'Saved addresses for delivery and tasks',
                route: '/profile/addresses',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Logout Button
          _buildLogoutButton(context),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle logout
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Perform logout
                    Navigator.pop(context);
                    // Navigate to login screen
                    context.go('/login');
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
