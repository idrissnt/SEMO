import 'package:go_router/go_router.dart';
import 'package:semo/features/store/presentation/screens/store_detail_screen.dart';
import 'package:semo/features/store/presentation/screens/product_screen.dart';
import 'package:semo/features/store/routes/store_routes_const.dart';

/// Router configuration for store-related routes
class StoreRouter {
  /// Get all store routes
  static List<RouteBase> getStoreRoutes() {
    return [
      // Store detail route with nested routes for tabs
      GoRoute(
        path: StoreRoutesConst.storeDetail,
        builder: (context, state) => StoreDetailScreen(
          storeId: state.pathParameters['storeId']!,
        ),
        routes: [
          // Aisles tab route
          GoRoute(
            path: StoreRoutesConst.storeAisles,
            builder: (context, state) => StoreDetailScreen(
              storeId: state.pathParameters['storeId']!,
              initialTab: 1, // Aisles tab index
            ),
          ),
          // Buy again tab route
          GoRoute(
            path: StoreRoutesConst.storeBuyAgain,
            builder: (context, state) => StoreDetailScreen(
              storeId: state.pathParameters['storeId']!,
              initialTab: 2, // Buy again tab index
            ),
          ),
          // Category products route - this is a sibling to the tab routes, not nested under aisles
          GoRoute(
            path: StoreRoutesConst.storeProductForAisle,
            builder: (context, state) => ProductScreen(
              storeId: state.pathParameters['storeId']!,
              aisleId: state.pathParameters['aisleId']!,
            ),
          ),
        ],
      ),
    ];
  }
}
