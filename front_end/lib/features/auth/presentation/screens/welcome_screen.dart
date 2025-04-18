// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/navigation/router_services/route_constants.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            painter: IosBackgroundPainter(),
            size: Size.infinite,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome to\nGrocery App',
                    style: context.headline1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your one-stop solution for all your grocery needs',
                    style: context.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 64),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.login),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white,
                      foregroundColor: context.primaryColor,
                    ),
                    child: Text(
                      'Login',
                      style: context.bodyLarge.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.go(AppRoutes.register),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      // side: const BorderSide(color: Colors.white),
                      backgroundColor: const Color.fromARGB(255, 24, 24, 24),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Register',
                      style: context.bodyLarge.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IosBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Draw the blue gradient background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color.fromARGB(255, 64, 71, 74), //
          Color(0xFF3A85F4), // Medium blue
          Color(0xFF5E5CE6), // Blue-purple
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Create the white blob shape
    final blobPath = Path();

    // Start from bottom left
    blobPath.moveTo(0, height);

    // Create the curved edge that goes from bottom left to middle right
    blobPath.quadraticBezierTo(
      width * 0.2, height * 0.7, // Control point
      width * 0.8, height * 0.5, // End point
    );

    // Continue the curve to the bottom right
    blobPath.quadraticBezierTo(
      width * 1.1, height * 0.4, // Control point (outside screen)
      width, height * 0.7, // End point
    );

    // Complete the shape
    blobPath.lineTo(width, height);
    blobPath.close();

    // Create a gradient for the light blue/gray blob with pink tints
    final blobPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromARGB(
              255, 193, 200, 204), // Very light blue with slight pink tint
          Color(0xFFEDF0F7), // Light blue-gray
          Color.fromARGB(
              255, 184, 166, 190), // Light blue-gray with slight pink tint
        ],
        stops: [0.2, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, height * 0.4, width, height * 0.6));

    // Draw the white blob
    canvas.drawPath(blobPath, blobPaint);

    // Add subtle pink highlight on top left
    final highlightPath = Path();
    highlightPath.moveTo(0, 0);
    highlightPath.lineTo(width * 0.5, 0);
    highlightPath.lineTo(0, height * 0.3);
    highlightPath.close();

    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFF5E1E9)
              .withOpacity(0.3), // Light pink with transparency
          const Color(0xFFF5E1E9).withOpacity(0.0), // Fading out
        ],
      ).createShader(Rect.fromLTWH(0, 0, width * 0.5, height * 0.3));

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
