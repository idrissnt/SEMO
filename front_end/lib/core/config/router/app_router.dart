// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/repositories/user_auth/auth_repository.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/auth/auth_state.dart';
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
      
      // Get the AuthRepository from the provider
      final authRepository = context.read<AuthRepository>();
      final prefs = await SharedPreferences.getInstance();

      // Get tokens from the repository
      final accessToken = await authRepository.getAccessToken();
      final refreshToken = await authRepository.getRefreshToken();

      // Comprehensive token validation
      final hasValidTokens = accessToken != null &&
          refreshToken != null &&
          accessToken.isNotEmpty &&
          refreshToken.isNotEmpty;

      // Combine token check with authentication state
      final isAuthenticated = hasValidTokens &&
          (authState is AuthAuthenticated ||
              await authRepository.hasValidToken());

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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.error}'),
      ),
    ),
  );
}
