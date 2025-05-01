// Dart and Flutter imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports
import 'package:semo/core/presentation/navigation/routes_constants/route_constants.dart';
import 'package:semo/core/presentation/navigation/app_routes/routing_transitions.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:semo/features/auth/presentation/screens/login_screen.dart';
import 'package:semo/features/auth/presentation/screens/registration_screen.dart';
import 'package:semo/features/auth/presentation/screens/welcome_screen.dart';

final AppLogger logger = AppLogger();

/// Class that handles all authentication-related routing
class AuthRouter {
  /// Returns all authentication-related routes with iOS-style transitions
  static List<RouteBase> getAuthRoutes() {
    return [
      GoRoute(
        path: AppRoutes.welcome,
        name: 'welcome',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const WelcomeScreen(),
          name: 'WelcomeScreen',
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
          name: 'LoginScreen',
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const RegistrationScreen(),
          name: 'RegistrationScreen',
        ),
      ),
    ];
  }

  /// Determines if the current route is an authentication-related route
  static bool isAuthRoute(String path) {
    return path == AppRoutes.login ||
        path == AppRoutes.register ||
        path == AppRoutes.welcome;
  }

  /// Auth routes redirect function that handles authentication logic
  static Future<String?> authRedirect(
      BuildContext context, GoRouterState state) async {
    // Get current auth state
    final authState = context.read<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticated;
    final isAuthRoute = AuthRouter.isAuthRoute(state.uri.path);

    // Check if the user is a guest user
    bool isGuestUser = false;
    if (authState is AuthAuthenticated) {
      isGuestUser = authState.user.isGuest;
    }

    if (isGuestUser) {
      logger.info('Guest user accessing: ${state.uri.path}');
      // Allow guest users to access non-auth routes
      return null; // No redirect needed for guest users
    }

    // If authenticated, prevent access to auth routes
    if (isAuthenticated && isAuthRoute) {
      return AppRoutes.home;
    }

    // If not authenticated, redirect to login
    if (!isAuthenticated && !isAuthRoute) {
      return AppRoutes.welcome;
    }

    return null; // no redirect needed
  }
}
