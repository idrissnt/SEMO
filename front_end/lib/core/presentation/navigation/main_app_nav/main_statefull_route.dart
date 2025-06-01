import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:semo/core/presentation/navigation/main_app_nav/bottom_navigation/bloc_provider/shell_provider.dart';
import 'package:semo/core/presentation/navigation/main_app_nav/bottom_navigation/main_shell_route.dart';

import 'package:semo/features/community_shop/routes/community_shop_routes.dart';
import 'package:semo/features/order/routes/order_routes.dart';
import 'package:semo/features/profile/routes/profile_routes.dart';

class MainShellRouter {
  static StatefulShellRoute getMainShellRoute() => StatefulShellRoute(
        builder: (context, state, child) {
          return MultiBlocProvider(
            providers: ShellProviderRegistry.getAllBlocProviders(),
            child: child,
          );
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          // Return your bottom navigation scaffold with the navigationShell
          return MainNavigationScaffold(
            navigationShell: navigationShell,
            children: children,
          );
        },
        branches: [
          // Each branch represents a tab with its nested routes
          StatefulShellBranch(
            routes: OrderRouter.getOrderRoutes(),
          ),
          StatefulShellBranch(
            routes: CommunityShopRouter.getCommunityShopRoutes(),
          ),

          StatefulShellBranch(
            routes: ProfileRouter.getProfileRoutes(),
          ),
        ],
      );
}
