import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A custom page that doesn't animate when transitioning between tabs
class TabNoTransitionPage<T> extends CustomTransitionPage<T> {
  /// Creates a page with no transition animation
  TabNoTransitionPage({
    required Widget child,
    required String name,
    Object? arguments,
    String? restorationId,
    LocalKey? key,
  }) : super(
          child: child,
          key: key ?? ValueKey(name),
          name: name,
          arguments: arguments,
          restorationId: restorationId,
          transitionsBuilder: (_, __, ___, child) => child,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
}
