import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
