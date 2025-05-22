// In features/order/routes/order_routes.dart
import 'package:go_router/go_router.dart';
import 'package:semo/features/message/message_screen.dart';
import 'package:semo/features/message/routes/const.dart';

class MessageRouter {
  // Get all routes for the Order feature
  static List<RouteBase> getMessageRoutes() {
    return [
      // Define the base route that matches the tab
      GoRoute(
        path: MessageRoutesConstants.message,
        builder: (_, __) => const MessageScreen(),
      ),
    ];
  }
}
