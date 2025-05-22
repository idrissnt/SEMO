// In features/order/routes/order_routes.dart
import 'package:go_router/go_router.dart';
import 'package:semo/features/order/presentation/screens/order_screen.dart';
import 'package:semo/features/order/presentation/screens/product_by_store_screen.dart';
import 'package:semo/features/order/routes/const.dart';

class OrderRouter {
  // Get all routes for the Order feature
  static List<RouteBase> getOrderRoutes() {
    return [
      // Define the base route that matches the tab
      GoRoute(
        path: OrderRoutesConstants.order,
        builder: (_, __) => const OrderScreen(),
        routes: [
          // Nested routes within the Order tab
          GoRoute(
            path: 'storeName/aisleName/categoryName/productName',
            builder: (_, state) => ProductByStoreScreen(
              storeId: state.pathParameters['storeName']!,
              aisleId: state.pathParameters['aisleName']!,
            ),
          ),
          // More nested routes...
        ],
      ),
    ];
  }
}
