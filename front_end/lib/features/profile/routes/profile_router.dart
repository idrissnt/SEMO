import 'package:go_router/go_router.dart';
import 'package:semo/features/profile/routes/flows/main_routes.dart';

/// Main router class for the Community Shop feature
class ProfileRouter {
  /// Get all routes for the Community Shop feature
  static List<RouteBase> getRoutes() {
    return MainProfileRoutes.getRoutes();
  }
}
