import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/cart/domain/entities/cart.dart';

/// An animated cart bar that transitions between different visual states
class AnimatedCartBar extends StatefulWidget {
  /// The cart data
  final Cart cart;

  /// Callback when the cart bar is tapped
  final VoidCallback onCartTap;

  /// Creates a new animated cart bar
  const AnimatedCartBar({
    Key? key,
    required this.cart,
    required this.onCartTap,
  }) : super(key: key);

  @override
  State<AnimatedCartBar> createState() => _AnimatedCartBarState();
}

class _AnimatedCartBarState extends State<AnimatedCartBar>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _entryController;
  late AnimationController _transformController;
  late AnimationController _finalController;

  // Animations
  late Animation<double> _scaleAnimation;
  late Animation<double> _positionAnimation;
  late Animation<double> _shapeAnimation;
  late Animation<double> _gradientAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Entry animation (logo coming from bottom)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Transform animation (logo to gradient)
    _transformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Final animation (gradient to solid blue)
    _finalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Scale animation for the logo
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack));

    // Position animation for entry from bottom
    _positionAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
        CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));

    // Shape animation (circle to rounded rectangle)
    _shapeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _transformController, curve: Curves.easeInOut));

    // Gradient animation with sliding effect
    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _transformController, curve: Curves.easeInOut));

    // Content fade in animation
    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _finalController, curve: Curves.easeIn));

    // Start the animation sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Start with the entry animation
    await _entryController.forward();
    
    // Add a small delay before starting the transform animation
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Then do the transform animation
    await _transformController.forward();
    
    // Add a small delay before the final animation
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Finally do the content fade in
    await _finalController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _transformController.dispose();
    _finalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_entryController, _transformController, _finalController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _positionAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildAnimatedContainer(),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedContainer() {
    // Determine if we're in the logo phase, gradient phase, or final phase
    final bool isLogoPhase =
        _entryController.value == 1.0 && _transformController.value == 0.0;
    final bool isGradientPhase =
        _transformController.value > 0.0 && _transformController.value < 1.0;
    final bool isFinalPhase = _transformController.value == 1.0;

    // Use the gradient animation value for color interpolation
    final double gradientProgress = _gradientAnimation.value;

    // Calculate the shape based on animation value
    // 0.0 = circle, 1.0 = rounded rectangle
    const double borderRadius = 24.0;
    final BoxShape shape =
        _shapeAnimation.value < 0.5 ? BoxShape.circle : BoxShape.rectangle;

    // Determine the decoration based on the current phase
    BoxDecoration decoration;

    if (isLogoPhase || _transformController.value < 0.3) {
      // Logo phase - circular white container with logo
      decoration = BoxDecoration(
        color: Colors.white,
        shape: shape,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        image: const DecorationImage(
          image: NetworkImage(
              'https://semo-store-bucket.s3.eu-west-3.amazonaws.com/media/Screenshot+2025-05-14+at+22.35.40.png'),
          fit: BoxFit.contain,
        ),
      );
    } else if (isGradientPhase || _transformController.value < 1.0) {
      // Gradient phase - colorful gradient
      // Create a sliding effect for the gradient colors
      decoration = BoxDecoration(
        shape: shape,
        gradient: LinearGradient(
          // Animate the gradient positions to create sliding effect
          begin: Alignment(-(1.0 - gradientProgress) * 2, 0), // Slide from left
          end: Alignment(1.0 + gradientProgress, gradientProgress),
          // Use vibrant colors that slide across
          colors: [
            Colors.green,
            Colors.red,
            AppColors.primary,
            Colors.yellow.shade700,
          ],
          // Add more color stops for a more dynamic effect
          stops: [
            0.0,
            0.3 + (0.2 * gradientProgress),
            0.6 + (0.1 * gradientProgress),
            1.0,
          ],
        ),
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else {
      // Final phase - solid blue
      decoration = BoxDecoration(
        shape: BoxShape.rectangle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary,
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: widget.onCartTap,
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: decoration,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: isFinalPhase ? _buildCartContent() : null,
      ),
    );
  }

  Widget _buildCartContent() {
    return Opacity(
      opacity: _contentFadeAnimation.value,
      child: Row(
        children: [
          // Delivery fee and progress information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.cart.qualifiesForFreeDelivery
                      ? 'Free delivery'
                      : '\$${widget.cart.deliveryFee.toStringAsFixed(2)} delivery fee, spend \$${(widget.cart.minimumOrderValue - widget.cart.subtotal).toStringAsFixed(2)} more',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Progress bar
                Container(
                  height: 4,
                  margin: const EdgeInsets.only(top: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: widget.cart.progressToFreeDelivery,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cart button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                widget.cart.itemCount > 0
                    ? 'Cart • ${widget.cart.itemCount}'
                    : 'Cart',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
