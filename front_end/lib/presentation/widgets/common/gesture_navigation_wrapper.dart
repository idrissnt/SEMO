import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GestureNavigationWrapper extends StatefulWidget {
  final Widget child;
  final bool enableHomeGesture;
  final bool enableBackGesture;
  final VoidCallback? onHomeGesture;
  final VoidCallback? onBackGesture;

  const GestureNavigationWrapper({
    Key? key,
    required this.child,
    this.enableHomeGesture = true,
    this.enableBackGesture = true,
    this.onHomeGesture,
    this.onBackGesture,
  }) : super(key: key);

  @override
  State<GestureNavigationWrapper> createState() =>
      _GestureNavigationWrapperState();
}

class _GestureNavigationWrapperState extends State<GestureNavigationWrapper> {
  bool _isDraggingBack = false;
  double _startX = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: widget.enableHomeGesture
          ? (details) {
              if (details.primaryDelta! < -20) {
                if (widget.onHomeGesture != null) {
                  widget.onHomeGesture!();
                } else {
                  context.go('/homeScreen');
                }
              }
            }
          : null,

      // Back gesture - Track initial touch position
      onHorizontalDragStart: widget.enableBackGesture
          ? (details) {
              _startX = details.localPosition.dx;
              if (_startX < 20) {
                // Check if touch starts within 20 pixels from left edge
                _isDraggingBack = true;
              }
            }
          : null,

      // Back gesture - Handle drag
      onHorizontalDragUpdate: widget.enableBackGesture
          ? (details) {
              if (_isDraggingBack && details.primaryDelta! > 0) {
                final dragDistance = details.localPosition.dx - _startX;
                if (dragDistance > 50) {
                  // Trigger after dragging 50 pixels to the right
                  _isDraggingBack = false;
                  if (widget.onBackGesture != null) {
                    widget.onBackGesture!();
                  } else {
                    Navigator.maybePop(context);
                  }
                }
              }
            }
          : null,

      onHorizontalDragEnd: widget.enableBackGesture
          ? (details) {
              _isDraggingBack = false;
            }
          : null,

      onHorizontalDragCancel: widget.enableBackGesture
          ? () {
              _isDraggingBack = false;
            }
          : null,

      child: widget.child,
    );
  }
}

// Example of a screen using gestures
class GestureNavigationScreen extends StatelessWidget {
  final Widget child;

  const GestureNavigationScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureNavigationWrapper(
      child: child,
      onHomeGesture: () {
        // Custom home gesture behavior
        context.go('/homeScreen');
      },
      onBackGesture: () {
        // Try to pop the current route first, if not possible, go back using go_router
        if (!Navigator.canPop(context)) {
          context.pop();
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}
