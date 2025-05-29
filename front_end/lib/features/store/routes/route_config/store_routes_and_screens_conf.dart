// Store routes configuration
import 'package:go_router/go_router.dart';
import 'package:semo/features/store/domain/entities/aisles/store_aisle.dart';
import 'package:semo/features/store/domain/entities/store.dart';
import 'package:semo/features/store/presentation/screens/store_aisles_tab/product/product_screen.dart';
import 'package:semo/features/store/presentation/screens/store_aisles_tab/store_aisles_tab.dart';
import 'package:semo/features/store/presentation/screens/store_buy_again_tab/product_list_screen.dart';
import 'package:semo/features/store/presentation/screens/store_buy_again_tab/store_buy_again_tab.dart';
import 'package:semo/features/store/presentation/screens/store_shop_tab/store_shop_tab.dart';
import 'package:semo/features/store/routes/route_config/store_routes_const.dart';

/// Helper function to extract store ID from navigation state
String extractStoreId(GoRouterState state) {
  final store = state.extra;
  String storeId = 'default-store-id';

  // Handle different store types
  if (store is StoreBrand) {
    storeId = store.id;
  } else if (store is NearbyStore) {
    storeId = store.storeBrand.id;
  } else if (store is Map) {
    // Handle case where store might be passed as a Map
    storeId = store['id']?.toString() ?? 'default-store-id';
  }

  return storeId;
}

class StoreShopRouter {
  // Get all routes for the Store Shop tab
  static List<RouteBase> getMainStoreRoutes() {
    return [
      GoRoute(
        path: StoreRoutesConst.storeBase,
        name: StoreRoutesConst.storeName,
        builder: (context, state) {
          return const StoreShopTab();
        },
        routes: [
          GoRoute(
            path: StoreRoutesConst.productsQuickView,
            name: StoreRoutesConst.productsQuickViewName,
            builder: (context, state) {
              // Handle both direct URL navigation and navigation with extra data
              String storeId;
              String? aisleId;

              if (state.extra != null) {
                // If we have extra data, extract IDs from the StoreBrand
                final extraData = state.extra as StoreBrand;
                storeId = extraData.id;
                aisleId =
                    extraData.aisles != null && extraData.aisles!.isNotEmpty
                        ? extraData.aisles!.first.id
                        : null;
              } else {
                // For direct URL navigation, extract from path parameters
                storeId = state.pathParameters['storeName'] ?? 'default-store';
                aisleId = state.pathParameters['aisleName'];
              }

              // If aisleId is still null, use a default or handle appropriately
              aisleId ??= 'default-aisle';

              return ProductScreen(
                storeId: storeId,
                aisleId: aisleId,
              );
            },
          ),
        ],
      ),
    ];
  }
}

class AislesRouter {
  // Get all routes for the Store Aisles tab
  static List<RouteBase> getAislesRoutes() {
    return [
      // Aisles tab
      GoRoute(
        path: StoreRoutesConst.storeAisles,
        name: StoreRoutesConst.storeAislesName,
        builder: (context, state) {
          final storeId = extractStoreId(state);

          return StoreAislesTab(storeId: storeId);
        },
        routes: [
          // Category products route
          GoRoute(
            path: StoreRoutesConst.storeProductForAisle,
            name: StoreRoutesConst.storeProductForAisleName,
            builder: (context, state) {
              // Get the store ID from the same method used by parent route
              final storeId = extractStoreId(state);

              // Get aisle from extra
              final aisle = state.extra as StoreAisle;
              final aisleId = aisle.id;

              return ProductScreen(
                storeId: storeId,
                aisleId: aisleId,
              );
            },
          ),
        ],
      ),
    ];
  }
}

class BuyAgainRouter {
  // Get all routes for the Store Buy Again tab
  static List<RouteBase> getBuyAgainRoutes() {
    return [
      // Buy again tab
      GoRoute(
        path: StoreRoutesConst.storeBuyAgain,
        name: StoreRoutesConst.storeBuyAgainName,
        builder: (context, state) {
          final storeId = extractStoreId(state);

          return StoreBuyAgainTab(storeId: storeId);
        },
        routes: [
          // Product list route
          GoRoute(
            path: StoreRoutesConst.storeProductList,
            name: StoreRoutesConst.storeProductListName,
            builder: (context, state) {
              // Get data from extra parameter
              final extraData = state.extra as Map<String, dynamic>;
              final products = extraData['products'] as List<CategoryProduct>;
              final storeId = extraData['storeId'] as String;

              return ProductListScreen(
                products: products,
                storeId: storeId,
              );
            },
          ),
        ],
      ),
    ];
  }
}
