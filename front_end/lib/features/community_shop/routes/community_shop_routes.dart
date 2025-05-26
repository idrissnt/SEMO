// In features/order/routes/order_routes.dart
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/config/routing_transitions.dart';
import 'package:semo/features/community_shop/presentation/screens/community_shop_screen.dart';
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
        // routes: [
        //   GoRoute(
        //     path: CommunityShopRoutesConstants.communityShop,
        //     name: CommunityShopRoutesConstants.communityShopName,
        //     pageBuilder: (context, state) => buildPageWithTransition(
        //       context: context,
        //       state: state,
        //       child: const CommunityShopScreen(),
        //       name: 'CommunityShopScreen',
        //     ),
        //   ),
        // ],
      ),
    ];
  }
}
