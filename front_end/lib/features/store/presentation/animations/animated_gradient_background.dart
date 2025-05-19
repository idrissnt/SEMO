import 'package:flutter/material.dart';
import 'dart:math' show pi, cos, sin;
import 'package:semo/core/presentation/theme/app_colors.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final double height;
  final List<Color>? colors;
  final Duration animationDuration;

  const AnimatedGradientBackground({
    Key? key,
    required this.child,
    required this.height,
    this.colors,
    this.animationDuration = const Duration(seconds: 100),
  }) : super(key: key);

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientAnimationController;

  @override
  void initState() {
    super.initState();

    // Initialize gradient animation controller
    _gradientAnimationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(); // Makes the animation loop continuously
  }

  @override
  void dispose() {
    _gradientAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultColors = [
      Colors.green,
      Colors.red,
      AppColors.primary,
      Colors.yellow.shade700,
    ];

    return Stack(
      children: [
        // Animated gradient background
        AnimatedBuilder(
          animation: _gradientAnimationController,
          builder: (context, _) => Container(
            width: double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(
                  cos(_gradientAnimationController.value * 2 * pi),
                  sin(_gradientAnimationController.value * 2 * pi),
                ),
                end: Alignment(
                  cos((_gradientAnimationController.value + 0.5) * 2 * pi),
                  sin((_gradientAnimationController.value + 0.5) * 2 * pi),
                ),
                colors: widget.colors ?? defaultColors,
              ),
            ),
          ),
        ),

        // Child content
        widget.child,
      ],
    );
  }
}
