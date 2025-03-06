// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../domain/services/auth_service.dart';
import '../../../presentation/screens/profile/profile_screen.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
import '../../utils/logger.dart';
import 'auth_routes.dart';
import 'main_shell_route.dart';
import 'store_shell_route.dart';
export 'route_extensions.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) async {
      // Get AuthBloc state first before any async operations
      final authState = context.read<AuthBloc>().state;

      final authService = AuthService(
        storage: const FlutterSecureStorage(),
        logger: AppLogger(),
      );
      final prefs = await SharedPreferences.getInstance();

      // Get tokens and check validity
      final accessToken = await authService.getAccessToken();
      final refreshToken = await authService.getRefreshToken();

      // Comprehensive token validation
      final hasValidTokens = accessToken != null &&
          refreshToken != null &&
          accessToken.isNotEmpty &&
          refreshToken.isNotEmpty;

      // Combine token check with authentication state
      final isAuthenticated = hasValidTokens &&
          (authState is AuthAuthenticated ||
              await authService.isAuthenticated());

      // Check onboarding status
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      // Routing logic
      if (!hasSeenOnboarding && state.uri.path != '/onboarding') {
        return '/onboarding';
      }

      if (hasSeenOnboarding && state.uri.path == '/onboarding') {
        return '/welcome';
      }

      // Authentication routes
      final isAuthRoute = state.uri.path == '/login' ||
          state.uri.path == '/register' ||
          state.uri.path == '/welcome';

      // If authenticated, prevent access to auth routes
      if (isAuthenticated && isAuthRoute) {
        return '/homeScreen';
      }

      // If not authenticated, redirect to login
      if (!isAuthenticated && !isAuthRoute && state.uri.path != '/onboarding') {
        return '/login';
      }

      return null; // no redirect needed
    },
    routes: [
      ...getAuthRoutes(),
      getMainShellRoute(),
      getStoreShellRoute(),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.error}'),
      ),
    ),
  );
}
