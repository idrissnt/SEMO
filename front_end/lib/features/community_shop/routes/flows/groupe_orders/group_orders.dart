import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/app_routes/app_router.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_group_orders/group_orders_screen.dart';
import 'package:semo/features/community_shop/routes/constants/route_constants.dart';
import 'package:semo/features/community_shop/routes/utils/route_builder.dart'
    as app_routes;

class GroupOrdersRoutes {
  /// Get all routes for the order details flow
  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: RouteConstants.groupOrders,
        name: RouteConstants.groupOrdersName,
        parentNavigatorKey: AppRouter.rootNavigatorKey,
        pageBuilder: buildGroupOrdersScreen,
      ),
    ];
  }

  static Page<dynamic> buildGroupOrdersScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    return app_routes.RouteBuilder.buildBottomToTopPage(
      context: context,
      state: state,
      child: const GroupOrdersScreen(),
      name: 'GroupOrdersScreen',
    );
  }
}
