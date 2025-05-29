// In features/order/routes/order_routes.dart

import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/config/routing_transitions.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/app_routes/app_router.dart';
import 'package:semo/features/community_shop/routes/transitions.dart';
import 'package:semo/features/community_shop/presentation/screens/accepted_order/order_started_screen.dart';
import 'package:semo/features/community_shop/presentation/screens/selected_order/community_order_details_screen.dart';
import 'package:semo/features/community_shop/presentation/screens/main_screen/community_shop_screen.dart';
import 'package:semo/features/community_shop/presentation/test_data/community_orders.dart';
import 'package:semo/features/community_shop/routes/const.dart';

class CommunityShopRouter {
  // Get all routes for the Order feature
  static List<RouteBase> getCommunityShopRoutes() {
    return [
      // Define the base route that matches the tab
      GoRoute(
        path: CommunityShopRoutesConstants.communityShop,
        name: CommunityShopRoutesConstants.communityShopName,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const CommunityShopScreen(),
          name: 'CommunityShopScreen',
        ),
        routes: [
          // Order details route
          GoRoute(
            path: CommunityShopRoutesConstants.orderDetails,
            name: CommunityShopRoutesConstants.orderDetailsName,
            parentNavigatorKey: AppRouter.rootNavigatorKey,
            pageBuilder: (context, state) => buildPageWithTransition(
              context: context,
              state: state,
              child: CommunityOrderDetailsScreen(
                order: state.extra as CommunityOrder,
              ),
              name: 'CommunityOrderDetailsScreen',
            ),
          ),
          GoRoute(
            path: CommunityShopRoutesConstants.orderStart,
            name: CommunityShopRoutesConstants.orderStartName,
            parentNavigatorKey: AppRouter.rootNavigatorKey,
            pageBuilder: (context, state) => buildBottomToTopTransition(
              context: context,
              state: state,
              child: CommunityOrderStartedScreen(
                order: state.extra as CommunityOrder,
              ),
              name: 'CommunityOrderStartedScreen',
            ),
          ),
        ],
      ),
    ];
  }
}
