import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A widget that adds iOS-style edge swipe navigation to its child.
///
/// This wrapper enables the native iOS-style swipe from left edge to go back
/// navigation gesture throughout the app.
class GestureNavigationWrapper extends StatefulWidget {
  final Widget child;
  final bool enableBackGesture;
  final VoidCallback? onBackGesture;

  const GestureNavigationWrapper({
    Key? key,
    required this.child,
    this.enableBackGesture = true,
    this.onBackGesture,
  }) : super(key: key);

  @override
  State<GestureNavigationWrapper> createState() =>
      _GestureNavigationWrapperState();
}

class _GestureNavigationWrapperState extends State<GestureNavigationWrapper> {
  bool _isDraggingBack = false;
  double _startX = 0;
  double _currentDragDistance = 0;

  // Constants for gesture detection
  static const double _edgeSwipeThreshold =
      20.0; // How close to the edge to start the gesture
  static const double _triggerThreshold =
      80.0; // How far to drag to trigger navigation
  static const double _dragOpacityFactor =
      0.003; // Factor for opacity calculation during drag

  @override
  Widget build(BuildContext context) {
    if (!widget.enableBackGesture) {
      return widget.child;
    }

    return Stack(
      children: [
        // Main content
        widget.child,

        // Gesture detector for edge swipe
        Positioned.fill(
          child: GestureDetector(
            // Detect when touch starts near the left edge
            onHorizontalDragStart: (details) {
              _startX = details.localPosition.dx;
              if (_startX < _edgeSwipeThreshold) {
                setState(() {
                  _isDraggingBack = true;
                  _currentDragDistance = 0;
                });
              }
            },

            // Track the drag movement
            onHorizontalDragUpdate: (details) {
              if (_isDraggingBack) {
                setState(() {
                  _currentDragDistance = (details.localPosition.dx - _startX)
                      .clamp(0.0, _triggerThreshold * 1.5);
                });

                // Trigger back navigation if dragged far enough
                if (_currentDragDistance > _triggerThreshold) {
                  _executeBackNavigation();
                }
              }
            },

            // Handle drag end
            onHorizontalDragEnd: (details) {
              if (_isDraggingBack) {
                // Check if the gesture was quick enough (swipe velocity)
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! > 300) {
                  _executeBackNavigation();
                } else if (_currentDragDistance > _triggerThreshold / 2) {
                  // Or if dragged more than half the threshold
                  _executeBackNavigation();
                }

                setState(() {
                  _isDraggingBack = false;
                  _currentDragDistance = 0;
                });
              }
            },

            // Reset on cancel
            onHorizontalDragCancel: () {
              setState(() {
                _isDraggingBack = false;
                _currentDragDistance = 0;
              });
            },

            // Make the gesture detector transparent to touch events when not dragging
            behavior: HitTestBehavior.translucent,
          ),
        ),

        // Visual feedback during drag (optional)
        if (_isDraggingBack)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _currentDragDistance * _dragOpacityFactor,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  color: Colors.black12,
                  alignment: Alignment.centerLeft,
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _executeBackNavigation() {
    if (widget.onBackGesture != null) {
      widget.onBackGesture!();
    } else {
      // Try to use the Navigator first, fallback to GoRouter
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        context.pop();
      }
    }

    setState(() {
      _isDraggingBack = false;
      _currentDragDistance = 0;
    });
  }
}

/// A screen widget that includes the gesture navigation wrapper.
/// Use this as a convenient way to wrap your screens with gesture navigation.
class GestureNavigationScreen extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBackGesture;

  const GestureNavigationScreen({
    Key? key,
    required this.child,
    this.onBackGesture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureNavigationWrapper(
      onBackGesture: onBackGesture ??
          () {
            // Try to pop the current route first, if not possible, go back using go_router
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.pop();
            }
          },
      child: child,
    );
  }
}
