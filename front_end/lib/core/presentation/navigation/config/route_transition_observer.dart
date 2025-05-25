import 'package:flutter/material.dart';

class RouteTransitionObserver extends NavigatorObserver {
  static final RouteTransitionObserver _instance =
      RouteTransitionObserver._internal();
  factory RouteTransitionObserver() => _instance;
  RouteTransitionObserver._internal();

  final Map<String, VoidCallback> _routeAnimationCallbacks = {};

  void registerRouteAnimationCallback(
      String routePattern, VoidCallback callback) {
    _routeAnimationCallbacks[routePattern] = callback;
  }

  void unregisterRouteAnimationCallback(String routePattern) {
    _routeAnimationCallbacks.remove(routePattern);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    final String routeName = route.settings.name ?? '';

    for (final pattern in _routeAnimationCallbacks.keys) {
      if (routeName.contains(pattern)) {
        _routeAnimationCallbacks[pattern]?.call();
        break;
      }
    }
  }
}
