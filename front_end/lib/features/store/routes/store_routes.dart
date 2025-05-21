import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/app_routes/app_router.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/presentation/screens/store_buy_again_tab/product_list_screen.dart';
import 'package:semo/features/store/presentation/screens/store_aisles_tab/product_screen.dart';
import 'package:semo/features/store/presentation/screens/store_shop_tab/store_shop_tab.dart';
import 'package:semo/features/store/presentation/screens/store_aisles_tab/store_aisles_tab.dart';
import 'package:semo/features/store/presentation/screens/store_buy_again_tab/store_buy_again_tab.dart';
import 'package:semo/features/store/routes/navigation/store_navigation_shell.dart';
import 'package:semo/features/store/routes/store_routes_const.dart';
import 'package:semo/features/store/routes/transitions/no_transition_page.dart';

/// Router configuration for store-related routes
class StoreRouter {
  /// Get all store routes
  static List<RouteBase> getStoreRoutes() {
    return [
      // Store detail route with ShellRoute for bottom navigation
      GoRoute(
        path: StoreRoutesConst.storeBase,
        redirect: (_, __) => null, // No-op redirect for the base path
      ),

      ShellRoute(
        builder: (context, state, child) {
          // Extract storeId from the path
          final String storeId = state.pathParameters['storeId'] ?? '';

          // Get the current route path to determine active tab
          final String path = state.uri.path;
          int selectedIndex = 0;

          // Determine the selected tab based on the path
          if (path.contains(StoreRoutesConst.storeAisles)) {
            selectedIndex = 1;
          } else if (path.contains(StoreRoutesConst.storeBuyAgain)) {
            selectedIndex = 2;
          }

          // Return a stateful shell that manages the bottom navigation
          return StoreNavigationShell(
            storeId: storeId,
            selectedIndex: selectedIndex,
            child: child,
          );
        },
        routes: [
          // Shop tab (default)
          GoRoute(
            path: StoreRoutesConst.selectedStore,
            name: StoreRoutesConst.storeDetailName,
            pageBuilder: (context, state) {
              final storeId = state.pathParameters['storeId'] ?? '';
              return TabNoTransitionPage(
                name: state.name!,
                child: StoreShopTab(storeId: storeId),
              );
            },
          ),
          // Aisles tab
          GoRoute(
            path:
                '${StoreRoutesConst.selectedStore}/${StoreRoutesConst.storeAisles}',
            name: StoreRoutesConst.storeAislesName,
            pageBuilder: (context, state) => TabNoTransitionPage(
              name: state.name!,
              child: StoreAislesTab(
                storeId: state.pathParameters['storeId']!,
              ),
            ),
            routes: [
              // Category products route
              GoRoute(
                path: StoreRoutesConst.storeProductForAisle,
                name: StoreRoutesConst.storeProductForAisleName,
                parentNavigatorKey: AppRouter.profileNavigatorKey,
                builder: (context, state) => ProductScreen(
                  storeId: state.pathParameters['storeId']!,
                  aisleId: state.pathParameters['aisleId']!,
                ),
              ),
            ],
          ),

          // Buy again tab
          GoRoute(
            path:
                '${StoreRoutesConst.selectedStore}/${StoreRoutesConst.storeBuyAgain}',
            name: StoreRoutesConst.storeBuyAgainName,
            pageBuilder: (context, state) => TabNoTransitionPage(
              name: state.name!,
              child: StoreBuyAgainTab(
                storeId: state.pathParameters['storeId']!,
              ),
            ),
            routes: [
              // Product list route
              GoRoute(
                path: StoreRoutesConst.storeProductList,
                name: StoreRoutesConst.storeProductListName,
                parentNavigatorKey: AppRouter.profileNavigatorKey,
                builder: (context, state) {
                  // Get products from the navigation state
                  final List<CategoryProduct> products =
                      state.extra as List<CategoryProduct>;
                  return ProductListScreen(
                    products: products,
                    storeId: state.pathParameters['storeId']!,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
