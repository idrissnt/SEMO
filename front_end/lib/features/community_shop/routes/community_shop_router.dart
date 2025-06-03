import 'package:go_router/go_router.dart';
import 'package:semo/features/community_shop/routes/flows/main_shop_routes.dart';

/// Main router class for the Community Shop feature
class CommunityShopRouter {
  /// Get all routes for the Community Shop feature
  static List<RouteBase> getRoutes() {
    return MainShopRoutes.getRoutes();
  }
}
