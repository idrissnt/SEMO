import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/auth/routes/auth_routes_const.dart';
import 'package:semo/features/profile/presentation/widgets/settings_section.dart';
import 'package:semo/features/profile/presentation/widgets/settings_tile.dart';
import 'package:semo/features/profile/routes/profile_routes_const.dart';
import 'package:semo/features/profile/presentation/widgets/personal_info_bottom_sheet.dart';

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
          SettingsSection(
            title: 'Account',
            children: [
              SettingsTile(
                icon: Icons.person_outline,
                title: 'Personal Information',
                subtitle: 'Name, email, phone number',
                onTap: () => _showPersonalInfoBottomSheet(context),
              ),
              const SettingsTile(
                icon: Icons.lock_outline,
                title: 'Security',
                subtitle: 'Password, verification, login activity',
                routeName: ProfileRouteNames.security,
              ),
              const SettingsTile(
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                subtitle: 'Credit cards, bank accounts',
                routeName: ProfileRouteNames.paymentMethods,
              ),
              const SettingsTile(
                icon: Icons.location_on_outlined,
                title: 'Addresses',
                subtitle: 'Saved addresses for delivery and tasks',
                routeName: ProfileRouteNames.addresses,
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

  // Helper method to show the personal info bottom sheet
  void _showPersonalInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,  // Enable dragging to dismiss
      isDismissible: true,  // Allow dismissing by tapping outside
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95, // Start at 95% of screen height
        minChildSize: 0.5,      // Allow dragging down to 50%
        maxChildSize: 0.95,     // Maximum 95% of screen height
        expand: false,
        builder: (context, scrollController) => PersonalInfoBottomSheet(scrollController: scrollController),
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
                    // Navigate to login screen
                    context.go(AuthRoutesConstants.login);
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

class AuthRoutes {}
