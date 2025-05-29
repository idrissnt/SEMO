import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/app_routes/app_router.dart';
import 'package:semo/core/presentation/navigation/config/routing_transitions.dart';
import 'package:semo/features/profile/presentation/screens/personal_info_screen.dart';
import 'package:semo/features/profile/presentation/screens/profile_settings_screen.dart';
import 'package:semo/features/profile/routes/profile_routes_const.dart';

/// Class that handles all profile-related routing
class ProfileRouter {
  /// Returns all profile-related routes with transitions
  static List<RouteBase> getProfileRoutes() {
    return [
      // Main profile settings screen
      GoRoute(
        path: ProfileRoutesConstants.rootProfile,
        name: ProfileRouteNames.profile,
        parentNavigatorKey: AppRouter.rootNavigatorKey,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ProfileSettingsScreen(),
          name: 'P',
        ),
        routes: [
          /// //===========================================================================
          /// Account Tab Routes
          /// //===========================================================================
          // Personal information screen
          GoRoute(
            path: ProfileRoutesConstants.accountPersonalInfo,
            name: ProfileRouteNames.personalInfo,
            pageBuilder: (context, state) => buildPageWithTransition(
              context: context,
              state: state,
              child: const PersonalInfoScreen(),
              name: 'PersonalInfoScreen',
            ),
          ),
          // Security screen - to be implemented
          GoRoute(
            path: ProfileRoutesConstants.accountSecurity,
            name: ProfileRouteNames.security,
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
            path: ProfileRoutesConstants.accountPaymentMethods,
            name: ProfileRouteNames.paymentMethods,
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
            path: ProfileRoutesConstants.accountAddresses,
            name: ProfileRouteNames.addresses,
            pageBuilder: (context, state) => buildPageWithTransition(
              context: context,
              state: state,
              child: const Scaffold(
                body: Center(child: Text('Addresses')),
              ),
              name: 'AddressesScreen',
            ),
          ),

          /// //===========================================================================
          /// Tasks Tab Routes
          /// //===========================================================================
          // Tasks section routes
          GoRoute(
            path: ProfileRoutesConstants.publishedTasks,
            name: ProfileRouteNames.publishedTasks,
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
            path: ProfileRoutesConstants.performedTasks,
            name: ProfileRouteNames.performedTasks,
            pageBuilder: (context, state) => buildPageWithTransition(
              context: context,
              state: state,
              child: const Scaffold(
                body: Center(child: Text('My Performed Tasks')),
              ),
              name: 'PerformedTasksScreen',
            ),
          ),

          /// //===========================================================================
          /// Grocery Tab Routes
          /// //===========================================================================
          // Grocery section routes
          GoRoute(
            path: ProfileRoutesConstants.groceryOrders,
            name: ProfileRouteNames.groceryOrders,
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
            path: ProfileRoutesConstants.groceryDeliveries,
            name: ProfileRouteNames.groceryDeliveries,
            pageBuilder: (context, state) => buildPageWithTransition(
              context: context,
              state: state,
              child: const Scaffold(
                body: Center(child: Text('My Grocery Deliveries')),
              ),
              name: 'GroceryDeliveriesScreen',
            ),
          ),

          /// //===========================================================================
          /// Settings Tab Routes
          /// //===========================================================================
        ],
      ),
    ];
  }
}
