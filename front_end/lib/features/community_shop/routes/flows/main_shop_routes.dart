import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/community_shop/presentation/screens/main_screen/community_shop_screen.dart';
import 'package:semo/features/community_shop/routes/constants/route_constants.dart';
import 'package:semo/features/community_shop/routes/flows/order_details/order_details_routes.dart';
import 'package:semo/features/community_shop/routes/flows/order_started/order_started_routes.dart';
import 'package:semo/features/community_shop/routes/utils/route_builder.dart'
    as app_routes;

/// Routes for the main community shop screen
class MainShopRoutes {
  /// Get all routes for the main community shop screen
  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: RouteConstants.communityShop,
        name: RouteConstants.communityShopName,
        pageBuilder: _buildCommunityShopScreen,
        routes: [
          ...OrderDetailsRoutes.getRoutes(),
          ...OrderStartedRoutes.getRoutes(),
        ],
      ),
    ];
  }

  /// Build the main community shop screen
  static Page<dynamic> _buildCommunityShopScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: const CommunityShopScreen(),
      name: 'CommunityShopScreen',
    );
  }
}
