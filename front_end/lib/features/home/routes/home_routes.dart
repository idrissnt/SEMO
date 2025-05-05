import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/routes_constants/route_constants.dart';
import 'package:semo/features/home/presentation/screens/home_screen.dart';
import 'package:semo/features/home/presentation/screens/category_details_screen.dart';
import 'package:semo/features/home/presentation/screens/product_details_screen.dart';
import 'package:semo/features/home/routes/home_routes_constants.dart';

/// Router configuration for home feature routes
class HomeRouter {
  /// Get all routes for the home feature
  static List<RouteBase> getHomeRoutes() {
    return [
      // Main home route with nested routes
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Category details route
          GoRoute(
            path: HomeRoutesConstants.categoryDetailsPath,
            builder: (context, state) {
              final categoryId = state.pathParameters['categoryId'] ?? '';
              return CategoryDetailsScreen(categoryId: categoryId);
            },
          ),
          // Product details route
          GoRoute(
            path: HomeRoutesConstants.productDetailsPath,
            builder: (context, state) {
              final productId = state.pathParameters['productId'] ?? '';
              return ProductDetailsScreen(productId: productId);
            },
          ),
        ],
      ),
    ];
  }
}
