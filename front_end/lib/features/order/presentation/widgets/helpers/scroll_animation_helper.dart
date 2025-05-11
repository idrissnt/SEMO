import 'package:flutter/material.dart';

/// Helper class for managing scroll-based animations
class ScrollAnimationHelper {
  final ScrollController scrollController;
  final double scrollThreshold;
  final Function(bool) onScrollStateChanged;
  bool _isScrolled = false;

  /// Constructor for ScrollAnimationHelper
  /// 
  /// [scrollController] - The controller for the scrollable widget
  /// [scrollThreshold] - The threshold at which the scroll state changes
  /// [onScrollStateChanged] - Callback when scroll state changes
  ScrollAnimationHelper({
    required this.scrollController,
    this.scrollThreshold = 40.0,
    required this.onScrollStateChanged,
  }) {
    _setupScrollListener();
  }

  /// Set up the scroll listener to detect when to change app bar state
  void _setupScrollListener() {
    scrollController.addListener(() {
      // Check if we've scrolled past the threshold
      if (scrollController.offset > scrollThreshold && !_isScrolled) {
        _isScrolled = true;
        onScrollStateChanged(_isScrolled);
      } else if (scrollController.offset <= scrollThreshold && _isScrolled) {
        _isScrolled = false;
        onScrollStateChanged(_isScrolled);
      }
    });
  }

  /// Dispose resources
  void dispose() {
    // Note: We don't dispose the scrollController here
    // as it might be used elsewhere. The owner should dispose it.
  }
}
