// In features/order/routes/order_routes.dart
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/config/routing_transitions.dart';
import 'package:semo/features/order/presentation/screens/notification.dart';
import 'package:semo/features/order/presentation/screens/order_screen.dart';
import 'package:semo/features/order/presentation/screens/product_by_store_screen.dart';
import 'package:semo/features/order/routes/const.dart';
import 'package:semo/features/store/domain/entities/store.dart';

class OrderRouter {
  // Get all routes for the Order feature
  static List<RouteBase> getOrderRoutes() {
    return [
      // Define the base route that matches the tab
      GoRoute(
        path: OrderRoutesConstants.order,
        name: OrderRoutesConstants.orderName,
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const OrderScreen(),
          name: 'OrderScreen',
        ),
        routes: [
          // Nested routes within the Order tab
          GoRoute(
            path: OrderRoutesConstants.productByStorePath,
            name: OrderRoutesConstants.productByStoreName,
            pageBuilder: (context, state) => buildPageWithTransition(
              context: context,
              state: state,
              child: ProductByStoreScreen(
                storeId: state.pathParameters['storeName']!,
                aisleId: state.pathParameters['aisleName']!,
                categoryId: state.pathParameters['categoryName'],
                // Get the store from extra data
                // The app bar passes the store data when navigating back
                store: (state.extra as Map<String, dynamic>)['store']
                    as StoreBrand,
              ),
              name: 'ProductByStoreScreen',
            ),
          ),
          // More nested routes...
          GoRoute(
            path: OrderRoutesConstants.notificationPath,
            name: OrderRoutesConstants.notificationName,
            pageBuilder: (context, state) => buildPageWithTransition(
              context: context,
              state: state,
              child: const NotificationScreen(),
              name: 'NotificationScreen',
            ),
          ),
        ],
      ),
    ];
  }
}
