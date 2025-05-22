import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:semo/core/di/injection_container.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/tab_registration/register_all_tabs.dart';
import 'package:semo/core/presentation/navigation/bottom_navigation/bloc_provider/register_shell_providers.dart';
import 'package:semo/core/presentation/navigation/app_routes/route_transition_observer.dart';
import 'package:semo/core/presentation/navigation/main_statefull_route.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';

import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/coordinators/auth_flow_coordinator.dart';
import 'package:semo/features/auth/routes/auth_routes.dart';
import 'package:semo/features/auth/routes/auth_routes_const.dart';
import 'package:semo/features/auth/routes/initial_route.dart';
import 'package:semo/features/order/routes/const.dart';

import 'package:semo/features/profile/routes/profile_routes.dart';
import 'package:semo/features/store/routes/main_store_route.dart';
import 'package:semo/features/store/routes/tabs/register_store_tabs.dart';

import 'navigation_logger.dart';

/// Central router configuration for the application
class AppRouter {
  /// Navigator key for profile routes
  static final GlobalKey<NavigatorState> profileNavigatorKey =
      GlobalKey<NavigatorState>();

  static final routeTransitionObserver = RouteTransitionObserver();

  /// Initialize the router
  static void initialize() {
    // Register all tabs from all features
    registerAllTabs();

    // Register all store tabs for the store navigation
    registerStoreTabs();

    // Register all shell providers from features
    registerAllShellProviders();
  }

  /// The main router for the app with navigation logging enabled
  static final GoRouter router = GoRouter(
    initialLocation: AuthRoutesConstants.splash,
    navigatorKey: profileNavigatorKey,
    redirect: (context, state) {
      // Skip redirection for splash screen
      if (state.uri.path == AuthRoutesConstants.splash) return null;

      // Use the AuthFlowCoordinator for centralized auth redirection
      try {
        // Get the AuthFlowCoordinator instance
        final coordinator = sl<AuthFlowCoordinator>();
        // Get the current auth state
        final authState = context.read<AuthBloc>().state;
        // Let the coordinator handle redirection
        return coordinator.handleRedirect(state.uri.path, authState);
      } catch (e) {
        // Fall back to AuthRouter if coordinator isn't available yet
        return AuthRouter.authRedirect(context, state);
      }
    },
    routes: [
      ...getInitialRoutes(),
      ...AuthRouter.getAuthRoutes(),
      MainShellRouter.getMainShellRoute(),
      ...ProfileRouter.getProfileRoutes(),
      MainStoreRouter.getMainStoreRoute(),
    ],
    observers: [
      NavigationLogger(),
      routeTransitionObserver,
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.r, color: AppColors.thirdColor),
            SizedBox(height: 16.h),
            Text('Route not found: ${state.error}'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => router.go(OrderRoutesConstants.order),
              child: Text('aller à la page des commandes',
                  style: TextStyle(
                    color: AppColors.textSecondaryColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ),
      ),
    ),
  );
}
