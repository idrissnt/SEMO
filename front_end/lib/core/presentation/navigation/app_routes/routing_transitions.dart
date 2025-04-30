import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Helper method to build a page with platform-appropriate transitions 
/// (iOS swipe gestures on iOS, Cupertino-style animations elsewhere).
Page<dynamic> buildPageWithTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  String? name,
}) {
  // On iOS, use CupertinoPage for native swipe gestures
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    return CupertinoPage<void>(
      key: state.pageKey,
      name: name,
      child: child,
      title: name, // Used for iOS accessibility
      // These ensure the swipe gesture works properly
      fullscreenDialog: false,
      maintainState: true,
    );
  } 
  // On other platforms, use CustomTransitionPage with Cupertino-style animations
  else {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      name: name,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return CupertinoPageTransition(
          primaryRouteAnimation: animation,
          secondaryRouteAnimation: secondaryAnimation,
          linearTransition: false,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }
}
