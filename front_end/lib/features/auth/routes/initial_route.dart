// Dart and Flutter imports
import 'package:go_router/go_router.dart';

// Project imports
import 'package:semo/core/presentation/navigation/routes_constants/route_constants.dart';
import 'package:semo/features/auth/presentation/screens/splash_screen.dart';

/// Returns all initial routes with iOS-style transitions
List<RouteBase> getInitialRoutes() {
  return [
    // Add splash screen route
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
  ];
}
