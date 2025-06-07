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
      transitionDuration: const Duration(milliseconds: 800),
      reverseTransitionDuration: const Duration(milliseconds: 800),
    );
  }
}

/// Builds a page with a bottom-to-top transition animation
/// The screen appears from the bottom and disappears to the top
Page<dynamic> buildBottomToTopTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  String? name,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: name,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // For appearing (coming in from bottom)
      const begin = Offset(0.0, 1.0); // Start from bottom
      const end = Offset.zero;

      // For dismissing (going out to top)
      const secondaryBegin = Offset.zero;
      const secondaryEnd = Offset(0.0, -1.0); // Exit to top

      final tween = Tween(begin: begin, end: end);
      final secondaryTween = Tween(begin: secondaryBegin, end: secondaryEnd);

      final offsetAnimation = animation.drive(tween);
      final secondaryOffsetAnimation = secondaryAnimation.drive(secondaryTween);

      return SlideTransition(
        position: offsetAnimation,
        child: SlideTransition(
          position: secondaryOffsetAnimation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
  );
}
