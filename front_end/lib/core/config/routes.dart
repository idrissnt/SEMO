// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/services/auth_service.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/welcome_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/mission/mission_screen.dart';
import '../../presentation/screens/earn/earn_screen.dart';
import '../../presentation/screens/message/message_screen.dart';
import '../../presentation/screens/semo_ai/semo_ai_screen.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart';
import '../utils/logger.dart';

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
        return '/';
      }

      // If not authenticated, redirect to login
      if (!isAuthenticated && !isAuthRoute && state.uri.path != '/onboarding') {
        return '/login';
      }

      return null; // no redirect needed
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/main',
        redirect: (context, state) => '/',
      ),
      ShellRoute(
        builder: (context, state, child) {
          int initialIndex = 0;
          final location = state.uri.path;

          if (location.startsWith('/mission')) {
            initialIndex = 1;
          } else if (location.startsWith('/earn')) {
            initialIndex = 2;
          } else if (location.startsWith('/message')) {
            initialIndex = 3;
          } else if (location.startsWith('/semo-ai')) {
            initialIndex = 4;
          }

          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: initialIndex,
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/mission');
                    break;
                  case 2:
                    context.go('/earn');
                    break;
                  case 3:
                    context.go('/message');
                    break;
                  case 4:
                    context.go('/semo-ai');
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Accueil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_outlined),
                  activeIcon: Icon(Icons.assignment),
                  label: 'Déléguer',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.monetization_on_outlined),
                  activeIcon: Icon(Icons.monetization_on),
                  label: 'Taf & Cash',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message_outlined),
                  activeIcon: Icon(Icons.message),
                  label: 'Message',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.psychology_outlined),
                  activeIcon: Icon(Icons.psychology),
                  label: 'SEMO AI',
                ),
              ],
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/mission',
            builder: (context, state) => const MissionScreen(),
          ),
          GoRoute(
            path: '/earn',
            builder: (context, state) => const EarnScreen(),
          ),
          GoRoute(
            path: '/message',
            builder: (context, state) => const MessageScreen(),
          ),
          GoRoute(
            path: '/semo-ai',
            builder: (context, state) => const SemoAIScreen(),
          ),
        ],
      ),
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

// Extension method to simplify navigation
extension GoRouterExtension on BuildContext {
  void pushRoute(String location) => go(location);
  void replaceRoute(String location) => replace(location);
}
