import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:semo/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:semo/features/auth/routes/auth_routes_const.dart';
import 'package:semo/features/order/routes/const.dart';

/// Coordinates authentication flow throughout the app
/// Serves as the single source of truth for auth-based navigation
class AuthFlowCoordinator {
  final AuthBloc _authBloc;
  final GoRouter _router;
  final AppLogger _logger;
  late final StreamSubscription<AuthState> _authSubscription;

  // Singleton instance for global access
  static AuthFlowCoordinator? _instance;

  // Factory constructor to return the singleton instance
  factory AuthFlowCoordinator.getInstance({
    required AuthBloc authBloc,
    required GoRouter router,
    required AppLogger logger,
  }) {
    _instance ??= AuthFlowCoordinator._internal(authBloc, router, logger);
    return _instance!;
  }

  // Internal constructor
  AuthFlowCoordinator._internal(this._authBloc, this._router, this._logger) {
    _authSubscription = _authBloc.stream.listen(_handleAuthStateChange);
    _logger.debug('AuthFlowCoordinator initialized');
  }

  // Public constructor for DI systems that manage their own singletons
  AuthFlowCoordinator({
    required AuthBloc authBloc,
    required GoRouter router,
    required AppLogger logger,
  })  : _authBloc = authBloc,
        _router = router,
        _logger = logger {
    _instance = this;
    _authSubscription = _authBloc.stream.listen(_handleAuthStateChange);
    _logger.debug('AuthFlowCoordinator initialized');
  }

  /// Handle auth state changes and coordinate navigation
  void _handleAuthStateChange(AuthState state) {
    _logger.debug(
        'AuthFlowCoordinator: Handling state change: ${state.runtimeType}');

    // Get the current location from the router configuration
    final location = _router.routerDelegate.currentConfiguration.uri.path;
    _logger.debug('Current location: $location');

    if (state is AuthUnauthenticated) {
      // When user logs out, navigate to welcome screen
      _logger.info('User logged out, navigating to welcome screen');
      _router.go(AuthRoutesConstants.welcome);
    } else if (state is AuthAuthenticated) {
      // When user logs in, navigate to home if currently on an auth screen
      _logger.debug('User authenticated, current location: $location');

      if (isAuthRoute(location)) {
        _logger.info(
            'User authenticated while on auth screen, navigating to home');
        _router.go(OrderRoutesConstants.order);
      }
    } else if (state is AuthLoading) {
      _logger.debug('Auth loading state detected');
      // Don't navigate during loading
    } else {
      _logger.debug('Other auth state detected: ${state.runtimeType}');
    }
  }

  /// Check if the current route is an authentication route
  /// Made public so it can be used by the router and other components
  bool isAuthRoute(String location) {
    return location == AuthRoutesConstants.welcome ||
        location == AuthRoutesConstants.login ||
        location == AuthRoutesConstants.register ||
        location == AuthRoutesConstants.splash;
  }

  /// Centralized auth redirect logic for the router
  /// This replaces the redirect logic in AuthRouter
  String? handleRedirect(String path, AuthState state) {
    _logger.debug('AuthFlowCoordinator: Handling redirect for path: $path');

    final isAuthenticated = state is AuthAuthenticated;
    final isAuthPath = isAuthRoute(path);

    // Check if the user is a guest user
    bool isGuestUser = false;
    if (state is AuthAuthenticated) {
      isGuestUser = state.user.isGuest;
    }

    if (isGuestUser) {
      _logger.info('Guest user accessing: $path');
      // Allow guest users to access non-auth routes
      return null; // No redirect needed for guest users
    }

    // If authenticated, prevent access to auth routes
    if (isAuthenticated && isAuthPath) {
      _logger.info('Authenticated user redirected from auth route to home');
      return OrderRoutesConstants.order;
    }

    // If not authenticated, redirect to welcome
    if (!isAuthenticated && !isAuthPath && path != AuthRoutesConstants.splash) {
      _logger.info('Unauthenticated user redirected to welcome screen');
      return AuthRoutesConstants.welcome;
    }

    return null; // no redirect needed
  }

  /// Handle initial navigation from splash screen
  /// This centralizes the initial navigation logic
  void handleSplashNavigation() {
    _logger.debug('AuthFlowCoordinator: Handling splash navigation');

    // Trigger auth check
    _authBloc.add(AuthCheckRequested());

    // Default to welcome screen
    // The auth state change handler will redirect if needed
    _router.go(AuthRoutesConstants.welcome);
  }

  /// Dispose resources
  void dispose() {
    _logger.debug('Disposing AuthFlowCoordinator');
    _authSubscription.cancel();
    _instance = null;
  }
}
