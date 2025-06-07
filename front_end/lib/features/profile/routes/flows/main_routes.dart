import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/config/route_builder.dart'
    as app_routes;
import 'package:semo/features/profile/presentation/screens/main_profile_screen.dart';
import 'package:semo/features/profile/routes/constant/base_profile_routes_const.dart';
import 'package:semo/features/profile/routes/flows/account/account_routes.dart';

/// Class that handles all profile-related routing
class MainProfileRoutes {
  /// Returns all profile-related routes with transitions
  static List<RouteBase> getRoutes() {
    return [
      // Main profile settings screen
      GoRoute(
        path: ProfileRoutesConstants.rootProfile,
        name: ProfileRouteNames.profileRouteName,
        pageBuilder: _buildMainProfileScreen,
        routes: [
          ...AccountRoutes.getRoutes(),
        ],
      ),
    ];
  }

  /// Build the main profile screen
  static Page<dynamic> _buildMainProfileScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: const MainProfileScreen(),
      name: 'MainProfileScreen',
    );
  }
}
