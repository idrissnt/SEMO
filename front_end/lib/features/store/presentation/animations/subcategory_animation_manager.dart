import 'package:flutter/material.dart';

/// Class that manages the animations for the subcategory screen
class SubcategoryAnimationManager {
  /// Animation controller for the filter bar transition
  final AnimationController filterController;

  /// Animation controller for the products appearance
  final AnimationController productsController;

  /// Animation for the filter bar transition
  late final Animation<double> filterAnimation;
  
  /// Animation for the filter slide-in from top
  late final Animation<Offset> filterSlideAnimation;

  /// Animation for the products appearance
  late final Animation<double> productsAnimation;
  
  /// Animation for the products slide-in from top
  late final Animation<Offset> productsSlideAnimation;

  /// Callback to be executed when the animation sequence is complete
  final VoidCallback? onAnimationComplete;

  /// Creates a new subcategory animation manager
  SubcategoryAnimationManager({
    required this.filterController,
    required this.productsController,
    this.onAnimationComplete,
  }) {
    // Initialize animations with appropriate curves
    filterAnimation = CurvedAnimation(
      parent: filterController, 
      curve: Curves.easeOutQuad
    );
    
    // Slide-in animation for filters (from top)
    filterSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),  // Start from above the screen
      end: Offset.zero,              // End at normal position
    ).animate(CurvedAnimation(
      parent: filterController,
      curve: Curves.easeOutQuad,
    ));
    
    // Fade-in animation for products
    productsAnimation = CurvedAnimation(
      parent: productsController, 
      curve: Curves.easeOutQuad
    );
    
    // Slide-in animation for products (from behind filters)
    productsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),  // Start just behind filters
      end: Offset.zero,              // End at normal position
    ).animate(CurvedAnimation(
      parent: productsController,
      curve: Curves.easeOutQuad,
    ));
  }

  /// Starts the animation sequence with filters sliding in from the top, followed by products
  void startAnimationSequenceFromTheTop(BuildContext context) {
    reset();
    
    // Start the animation sequence - first filters, then products
    filterController.forward().then((_) {
      // After filter animation completes, start the products animation
      productsController.forward().whenComplete(() {
        // Notify when all animations are complete
        if (onAnimationComplete != null) {
          onAnimationComplete!();
        }
      });
    });
  }
  
  /// Resets the animation state
  void reset() {
    // Reset animation controllers to their initial state
    filterController.reset();
    productsController.reset();
  }
}
