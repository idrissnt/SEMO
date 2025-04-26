// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/auth/auth_routes.dart';

import 'previous/router_services/main_shell_route.dart';
import 'previous/router_services/navigation_logger.dart';
import 'previous/router_services/route_constants.dart';
// import 'store_shell_route.dart';
export 'previous/router_services/route_extensions.dart';

/// Central router configuration for the application
class AppRouter {
  /// The main router for the app with navigation logging enabled
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.welcome,
    redirect: AuthRouter.authRedirect,
    routes: [
      ...AuthRouter.getAuthRoutes(),
      getMainShellRoute(),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Route not found: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => router.go(AppRoutes.welcome),
              child: const Text('Go to Welcome Screen'),
            ),
          ],
        ),
      ),
    ),
    observers: [NavigationLogger()],
  );
}
