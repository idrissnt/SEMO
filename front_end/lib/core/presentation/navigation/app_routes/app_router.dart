import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/main_shell_route.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/register_all_tabs.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/bloc_provider/register_shell_providers.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/auth/routes/auth_routes.dart';
import 'package:semo/features/auth/routes/auth_routes_const.dart';
import 'package:semo/features/auth/routes/initial_route.dart';
import 'package:semo/features/profile/routes/profile_routes.dart';

import 'navigation_logger.dart';

/// Central router configuration for the application
class AppRouter {
  /// Navigator key for profile routes
  static final GlobalKey<NavigatorState> profileNavigatorKey =
      GlobalKey<NavigatorState>();

  /// Initialize the router
  static void initialize() {
    // Register all tabs from all features
    registerAllTabs();

    // Register all shell providers from features
    registerAllShellProviders();
  }

  /// The main router for the app with navigation logging enabled
  static final GoRouter router = GoRouter(
    initialLocation: AuthRoutesConstants.splash,
    navigatorKey: profileNavigatorKey,
    redirect: (context, state) {
      // Don't redirect from splash screen - let it handle navigation
      if (state.uri.path == AuthRoutesConstants.splash) return null;

      // Use existing auth redirect for other routes
      return AuthRouter.authRedirect(context, state);
    },
    routes: [
      ...getInitialRoutes(),
      ...AuthRouter.getAuthRoutes(),
      // Use the main shell route from core instead of home-specific route
      getMainShellRoute(),
      // Add profile routes directly at the top level
      ...ProfileRouter.getProfileRoutes(),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.r, color: AppColors.thirdColor),
            SizedBox(height: 16.h),
            Text('Route not found: ${state.error}'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => router.go(AuthRoutesConstants.welcome),
              child: Text('Go to Welcome Screen',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ),
      ),
    ),
    observers: [NavigationLogger()],
  );
}
