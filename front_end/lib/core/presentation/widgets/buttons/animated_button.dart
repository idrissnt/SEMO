import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

/// A button with animation effects for improved user feedback
///
/// This button provides:
/// - Scale animation when pressed
/// - Optional haptic feedback
/// - Custom splash effects
/// - Shadow animation
class AnimatedButton extends StatefulWidget {
  /// The callback to execute when the button is pressed
  final VoidCallback onPressed;

  /// The child widget to display inside the button
  final Widget child;

  /// The style of the button
  final ButtonStyle style;

  /// The color of the splash effect when the button is pressed
  final Color splashColor;

  /// The color of the highlight effect (for ripple effect)
  final Color highlightColor;

  /// The color of the shadow effect
  final Color boxShadowColor;

  /// The duration of the animation
  final Duration animationDuration;

  /// Whether to enable haptic feedback when the button is pressed
  final bool enableHapticFeedback;

  const AnimatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.style,
    required this.splashColor,
    required this.highlightColor,
    required this.boxShadowColor,
    this.animationDuration = const Duration(milliseconds: 350),
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  // For ripple effect
  final double _rippleSize = 0.0;
  Offset _ripplePosition = Offset.zero;
  bool _showRipple = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    // Using spring physics for more natural feel
    _controller.addListener(() => setState(() {}));

    // Scale animation with spring physics
    _scaleAnimation = _controller.drive(
      Tween<double>(begin: 1.0, end: 0.8).chain(
        CurveTween(curve: Curves.easeOutQuint),
      ),
    );

    // Shadow animation
    _shadowAnimation = _controller.drive(
      Tween<double>(begin: 0.5, end: 0.5).chain(
        CurveTween(curve: Curves.easeOutQuint),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    // Provide haptic feedback when button is pressed
    if (widget.enableHapticFeedback) {
      _triggerHapticFeedback();
    }

    // Use the center of the button for the ripple effect
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final size = box.size;
        setState(() {
          _ripplePosition = Offset(size.width / 2, size.height / 2);
          _showRipple = true;
        });
      }
    });
    _controller.forward();
  }

  Future<void> _triggerHapticFeedback() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 10); // 50 ms light vibration
    }
  }

  void _handleTapUp(TapUpDetails details) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _showRipple = false;
        });
      }
    });
    _controller.reverse().then((_) {
      widget.onPressed();
    });
  }

  void _handleTapCancel() {
    setState(() {
      _showRipple = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle effectiveStyle = widget.style;
    final Color splashColor = widget.splashColor;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                borderRadius: _extractBorderRadius(effectiveStyle),
                boxShadow: [
                  BoxShadow(
                    color: widget.boxShadowColor,
                    blurRadius: _shadowAnimation.value,
                    spreadRadius: _shadowAnimation.value,
                    offset: Offset(0, _shadowAnimation.value),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // The actual button
                  ElevatedButton(
                    onPressed: null, // We handle the press with GestureDetector
                    style: widget.style,
                    child: widget.child,
                  ),

                  // Ripple effect
                  if (_showRipple)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: _extractBorderRadius(effectiveStyle),
                        child: CustomPaint(
                          painter: RipplePainter(
                            center: _ripplePosition,
                            radius: _rippleSize,
                            color: splashColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Helper method to extract border radius from button style
BorderRadius _extractBorderRadius(ButtonStyle style) {
  // Try to get the shape from the style
  final shape = style.shape?.resolve({});

  // Default radius if we can't determine it
  double radius = 8.0;

  // If it's a rounded rectangle border, extract its radius
  if (shape is RoundedRectangleBorder) {
    final borderRadius = shape.borderRadius;
    if (borderRadius is BorderRadius) {
      return borderRadius;
    }
  }

  return BorderRadius.circular(radius);
}

class RipplePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;

  RipplePainter(
      {required this.center, required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Calculate ripple size based on button size to ensure full coverage
    final maxRadius = math.max(size.width, size.height);

    // Draw ripple effect that covers the entire button
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), maxRadius, paint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) =>
      center != oldDelegate.center ||
      radius != oldDelegate.radius ||
      color != oldDelegate.color;
}
