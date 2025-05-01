import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/app_routes/routing_transitions.dart';
import 'package:semo/core/presentation/navigation/routes_constants/route_constants.dart';
import 'package:semo/features/profile/presentation/screens/personal_info_screen.dart';
import 'package:semo/features/profile/presentation/screens/profile_settings_screen.dart';

/// Class that handles all profile-related routing
class ProfileRouter {
  /// Returns all profile-related routes with transitions
  static List<RouteBase> getProfileRoutes() {
    return [
      // Main profile settings screen
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ProfileSettingsScreen(),
          name: 'ProfileSettingsScreen',
        ),
        routes: [
          // Personal information screen
          GoRoute(
            path: 'personal-info',
            name: 'personal-info',
            pageBuilder: (context, state) => buildPageWithTransition(
              context: context,
              state: state,
              child: const PersonalInfoScreen(),
              name: 'PersonalInfoScreen',
            ),
          ),
          // Security screen - to be implemented
          GoRoute(
            path: 'security',
            name: 'security',
            pageBuilder: (context, state) => buildPageWithTransition(
              context: context,
              state: state,
              child: const Scaffold(
                body: Center(child: Text('Security Settings')),
              ),
              name: 'SecurityScreen',
            ),
          ),
          // Payment methods screen - to be implemented
          GoRoute(
            path: 'payment-methods',
            name: 'payment-methods',
            pageBuilder: (context, state) => buildPageWithTransition(
              context: context,
              state: state,
              child: const Scaffold(
                body: Center(child: Text('Payment Methods')),
              ),
              name: 'PaymentMethodsScreen',
            ),
          ),
          // Addresses screen - to be implemented
          GoRoute(
            path: 'addresses',
            name: 'addresses',
            pageBuilder: (context, state) => buildPageWithTransition(
              context: context,
              state: state,
              child: const Scaffold(
                body: Center(child: Text('Addresses')),
              ),
              name: 'AddressesScreen',
            ),
          ),
          // Tasks section routes
          GoRoute(
            path: 'published-tasks',
            name: 'published-tasks',
            pageBuilder: (context, state) => buildPageWithTransition(
              context: context,
              state: state,
              child: const Scaffold(
                body: Center(child: Text('My Published Tasks')),
              ),
              name: 'PublishedTasksScreen',
            ),
          ),
          GoRoute(
            path: 'performed-tasks',
            name: 'performed-tasks',
            pageBuilder: (context, state) => buildPageWithTransition(
              context: context,
              state: state,
              child: const Scaffold(
                body: Center(child: Text('My Performed Tasks')),
              ),
              name: 'PerformedTasksScreen',
            ),
          ),
          // Grocery section routes
          GoRoute(
            path: 'grocery-orders',
            name: 'grocery-orders',
            pageBuilder: (context, state) => buildPageWithTransition(
              context: context,
              state: state,
              child: const Scaffold(
                body: Center(child: Text('My Grocery Orders')),
              ),
              name: 'GroceryOrdersScreen',
            ),
          ),
          GoRoute(
            path: 'grocery-deliveries',
            name: 'grocery-deliveries',
            pageBuilder: (context, state) => buildPageWithTransition(
              context: context,
              state: state,
              child: const Scaffold(
                body: Center(child: Text('My Grocery Deliveries')),
              ),
              name: 'GroceryDeliveriesScreen',
            ),
          ),
        ],
      ),
    ];
  }
}
