import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// A full-screen image viewer with hero animation support
class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const ImageViewerScreen({
    Key? key,
    required this.imageUrl,
    required this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.close, color: Colors.black),
            ),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: _SwipeToDismissWrapper(
        onDismiss: () => context.pop(),
        child: GestureDetector(
          // Close on tap anywhere
          onTap: () => context.pop(),
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: Hero(
              tag: heroTag,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A wrapper widget that allows dismissing its child with a vertical swipe gesture
class _SwipeToDismissWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onDismiss;

  const _SwipeToDismissWrapper({
    required this.child,
    required this.onDismiss,
  });

  @override
  State<_SwipeToDismissWrapper> createState() => _SwipeToDismissWrapperState();
}

class _SwipeToDismissWrapperState extends State<_SwipeToDismissWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _startPosition = Offset.zero;
  Offset _currentPosition = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() {
        if (_controller.isCompleted) {
          _currentPosition = Offset.zero;
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetPosition() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Detect the start of a drag
      onVerticalDragStart: (details) {
        setState(() {
          _startPosition = details.globalPosition;
          _isDragging = true;
        });
      },
      // Track the drag movement
      onVerticalDragUpdate: (details) {
        if (!_isDragging) return;

        setState(() {
          _currentPosition = Offset(
            0,
            details.globalPosition.dy - _startPosition.dy,
          );
        });
      },
      // Handle the end of a drag
      onVerticalDragEnd: (details) {
        // If dragged down more than 100 pixels, dismiss
        if (_currentPosition.dy > 100) {
          widget.onDismiss();
        } else {
          _resetPosition();
        }

        setState(() {
          _isDragging = false;
        });
      },
      // Apply the transformation based on drag position
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final offset = _isDragging
              ? _currentPosition
              : Offset(0, _currentPosition.dy * (1 - _controller.value));

          // Calculate opacity based on drag distance (fade out as user drags down)
          final opacity = 1.0 - (offset.dy.abs() / 500).clamp(0.0, 0.7);

          return Transform.translate(
            offset: offset,
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
