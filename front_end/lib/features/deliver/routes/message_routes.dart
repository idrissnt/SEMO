// In features/order/routes/order_routes.dart
import 'package:go_router/go_router.dart';
import 'package:semo/features/deliver/presentation/screens/community_shopping_screen.dart';
import 'package:semo/features/deliver/routes/const.dart';

class DeliverRouter {
  // Get all routes for the Order feature
  static List<RouteBase> getDeliverRoutes() {
    return [
      // Define the base route that matches the tab
      GoRoute(
        path: DeliverRoutesConstants.deliver,
        builder: (_, __) => const CommunityShoppingScreen(),
      ),
    ];
  }
}
