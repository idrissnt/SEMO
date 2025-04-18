import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/utils/logger.dart';

/// A middleware for logging navigation events
/// 
/// This class provides logging for navigation events, making it easier to
/// debug navigation issues and track user flows through the app.
class NavigationLogger extends NavigatorObserver {
  final AppLogger _logger = AppLogger();
  
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logNavigation(
      'PUSH',
      route: route,
      previousRoute: previousRoute,
    );
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logNavigation(
      'POP',
      route: route,
      previousRoute: previousRoute,
    );
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _logNavigation(
      'REPLACE',
      route: newRoute,
      previousRoute: oldRoute,
    );
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logNavigation(
      'REMOVE',
      route: route,
      previousRoute: previousRoute,
    );
    super.didRemove(route, previousRoute);
  }

  /// Helper method to log navigation events with consistent formatting
  void _logNavigation(
    String action, {
    Route<dynamic>? route,
    Route<dynamic>? previousRoute,
  }) {
    // Only log in debug mode
    if (!kDebugMode) return;
    
    final routeName = route?.settings.name ?? 'unknown';
    final routeArgs = route?.settings.arguments;
    final previousRouteName = previousRoute?.settings.name ?? 'none';
    
    _logger.debug('Navigation: $action → $routeName', {
      'from': previousRouteName,
      'to': routeName,
      'component': 'NavigationLogger',
      if (routeArgs != null) 'args': routeArgs.toString(),
    });
  }
}

/// Creates a GoRouter with navigation logging enabled
GoRouter createRouterWithLogging({
  required String initialLocation,
  required List<RouteBase> routes,
  GoRouterRedirect? redirect,
  Widget Function(BuildContext, GoRouterState)? errorBuilder,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: routes,
    redirect: redirect,
    errorBuilder: errorBuilder,
    observers: [NavigationLogger()],
  );
}
