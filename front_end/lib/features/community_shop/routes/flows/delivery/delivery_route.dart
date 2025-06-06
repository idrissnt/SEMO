import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/app_routes/app_router.dart';
import 'package:semo/features/community_shop/presentation/screens/shopper_delivery_screen/shopper_delivery_main_screen.dart';
import 'package:semo/features/community_shop/routes/constants/route_constants.dart';
import 'package:semo/features/community_shop/routes/utils/route_builder.dart'
    as app_routes;

class DeliveryRoutes {
  /// Get all routes for the order details flow
  static List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: RouteConstants.shopperDelivery,
        name: RouteConstants.shopperDeliveryName,
        parentNavigatorKey: AppRouter.rootNavigatorKey,
        pageBuilder: buildShopperDeliveryMainScreen,
      ),
    ];
  }

  static Page<dynamic> buildShopperDeliveryMainScreen(
    BuildContext context,
    GoRouterState state,
  ) {
    return app_routes.RouteBuilder.buildPage(
      context: context,
      state: state,
      child: const ShopperDeliveryMainScreen(),
      name: 'ShopperDeliveryMainScreen',
    );
  }
}
