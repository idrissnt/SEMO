import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/config/routing_transitions.dart';
import 'package:semo/features/community_shop/routes/transitions.dart';

/// Utility class for building routes with consistent transitions and parameter handling
class RouteBuilder {
  /// Builds a page with the standard transition
  static Page<dynamic> buildPage({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    required String name,
  }) {
    return buildPageWithTransition(
      context: context,
      state: state,
      child: child,
      name: name,
    );
  }

  /// Builds a page with bottom-to-top transition
  static Page<dynamic> buildBottomToTopPage({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    required String name,
  }) {
    return buildBottomToTopTransition(
      context: context,
      state: state,
      child: child,
      name: name,
    );
  }

  /// Safely extracts a parameter from state.extra
  static T? getExtraParam<T>(GoRouterState state, String key) {
    if (state.extra is! Map<String, dynamic>) return null;
    final extras = state.extra as Map<String, dynamic>;
    if (!extras.containsKey(key)) return null;

    try {
      return extras[key] as T;
    } catch (e) {
      debugPrint('Error extracting parameter $key: $e');
      return null;
    }
  }

  /// Creates an error page for missing parameters
  static Page<dynamic> errorPage(
    BuildContext context,
    GoRouterState state,
    String message,
  ) {
    return MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(child: Text(message)),
      ),
    );
  }
}
