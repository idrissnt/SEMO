import 'package:flutter/material.dart';

/// Class that manages the animations for the subcategory screen
class SubcategoryAnimationManager {
  /// Animation controller for the filter bar transition
  final AnimationController filterController;

  /// Animation controller for the elevation effect
  final AnimationController elevationController;

  /// Animation for the filter bar transition
  late final Animation<double> filterAnimation;

  /// Animation for the elevation effect
  late final Animation<double> elevationAnimation;

  /// Animation for the scale effect
  late final Animation<double> scaleAnimation;

  /// Animation for the position effect
  Animation<Offset>? positionAnimation;

  /// Stores the position of the tapped subcategory
  Offset? tappedItemPosition;

  /// Size of the tapped subcategory
  Size? tappedItemSize;

  /// Creates a new subcategory animation manager
  SubcategoryAnimationManager({
    required this.filterController,
    required this.elevationController,
  }) {
    // Initialize filter animation
    filterAnimation = CurvedAnimation(
      parent: filterController,
      curve: Curves.easeInOut,
    );

    // Initialize elevation animation
    elevationAnimation = CurvedAnimation(
      parent: elevationController,
      curve: Curves.easeOutQuad,
    );

    // Initialize scale animation
    scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: elevationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
  }

  /// Calculates the position of a widget using its global key
  void calculateItemPosition(GlobalKey key) {
    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      tappedItemPosition = renderBox.localToGlobal(Offset.zero);
      tappedItemSize = renderBox.size;
    }
  }

  /// Initializes the position animation
  void initPositionAnimation(double targetY) {
    // Calculate the distance to move from current position to the top
    final double startY = tappedItemPosition?.dy ?? 0;

    positionAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: Offset(0, targetY - startY),
    ).animate(CurvedAnimation(
      parent: elevationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuad),
    ));
  }

  /// Resets the animation state
  void reset() {
    tappedItemPosition = null;
    tappedItemSize = null;
    positionAnimation = null;
  }

  /// Builds the animated subcategory that elevates to the top
  Widget buildElevatedItem() {
    if (tappedItemPosition == null ||
        tappedItemSize == null ||
        positionAnimation == null ||
        elevationAnimation.value <= 0 ||
        elevationController.isCompleted) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: tappedItemPosition!.dx,
      top: tappedItemPosition!.dy +
          (positionAnimation!.value.dy * elevationAnimation.value),
      child: AnimatedBuilder(
        animation: elevationAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: Opacity(
              opacity: 1 - (elevationAnimation.value * 0.5),
              child: Material(
                elevation: 8 * elevationAnimation.value,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: tappedItemSize!.width,
                  height: tappedItemSize!.height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
