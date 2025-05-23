// Replace the single shell route with a StatefulShellRoute
import 'package:go_router/go_router.dart';
import 'package:semo/features/store/routes/route_config/store_bottom_nav_conf.dart';
import 'package:semo/features/store/routes/route_config/store_routes_and_screens_conf.dart';

class MainStoreRouter {
  static StatefulShellRoute getMainStoreRoute() => StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return navigationShell;
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          // Return your bottom navigation scaffold with the navigationShell
          return StoreNavigationScaffold(
            navigationShell: navigationShell,
            children: children,
          );
        },
        branches: [
          // Each branch represents a tab with its nested routes
          StatefulShellBranch(
            routes: StoreShopRouter.getMainStoreRoutes(),
          ),
          StatefulShellBranch(
            routes: AislesRouter.getAislesRoutes(),
          ),
          StatefulShellBranch(
            routes: BuyAgainRouter.getBuyAgainRoutes(),
          ),
        ],
      );
}
