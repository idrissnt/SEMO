// Dart and Flutter imports
import 'package:go_router/go_router.dart';

// Project imports
import 'package:semo/features/auth/presentation/screens/splash_screen.dart';
import 'package:semo/features/auth/routes/auth_routes_const.dart';

/// Returns all initial routes with iOS-style transitions
List<RouteBase> getInitialRoutes() {
  return [
    // Add splash screen route
    GoRoute(
      path: AuthRoutesConstants.splash,
      builder: (context, state) => const SplashScreen(),
    ),
  ];
}
