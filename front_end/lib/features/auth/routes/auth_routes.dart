// Dart and Flutter imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports
import 'package:semo/core/presentation/navigation/config/routing_transitions.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:semo/features/auth/presentation/screens/login_screen.dart';
import 'package:semo/features/auth/presentation/screens/registration_screen.dart';
import 'package:semo/features/auth/presentation/screens/welcome_screen.dart';
import 'package:semo/features/auth/routes/auth_routes_const.dart';
import 'package:semo/features/order/routes/const.dart';

final AppLogger logger = AppLogger();

/// Class that handles all authentication-related routing
class AuthRouter {
  /// Returns all authentication-related routes with iOS-style transitions
  static List<RouteBase> getAuthRoutes() {
    return [
      GoRoute(
        path: AuthRoutesConstants.welcome,
        name: 'welcome',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const WelcomeScreen(),
          name: 'WelcomeScreen',
        ),
      ),
      GoRoute(
        path: AuthRoutesConstants.login,
        name: 'login',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
          name: 'LoginScreen',
        ),
      ),
      GoRoute(
        path: AuthRoutesConstants.register,
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
    return path == AuthRoutesConstants.login ||
        path == AuthRoutesConstants.register ||
        path == AuthRoutesConstants.welcome;
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
      return OrderRoutesConstants.order;
    }

    // If not authenticated, redirect to login
    if (!isAuthenticated && !isAuthRoute) {
      return AuthRoutesConstants.welcome;
    }

    return null; // no redirect needed
  }
}
