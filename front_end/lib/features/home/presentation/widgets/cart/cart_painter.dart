import 'package:flutter/material.dart';

/// A custom painter that draws a detailed shopping cart with transparent sections
/// based on the reference image, with a trapezoidal basket, handle, frame, and wheels.
class CartPainter extends CustomPainter {
  /// The main dark color of the cart (outline, handle, frame)
  final Color outlineColor;

  /// The fill color of the cart's basket
  final Color basketColor;

  /// The opacity of the cart's basket (0.0 to 1.0)
  final double basketOpacity;

  /// The color of the cart's wheel centers
  final Color wheelCenterColor;

  CartPainter({
    this.outlineColor = const Color(0xFF2D7DD2), // Dark blue
    this.basketColor = const Color.fromARGB(255, 166, 212, 233), // Light blue
    this.basketOpacity = 0.5,
    this.wheelCenterColor = const Color(0xFF8ECAE6), // Light blue
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Define all the paints
    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.03
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = basketColor.withValues(alpha: basketOpacity)
      ..style = PaintingStyle.fill;

    final wheelOutlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.fill;

    final wheelCenterPaint = Paint()
      ..color = wheelCenterColor
      ..style = PaintingStyle.fill;

    final slitsPaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.02
      ..strokeCap = StrokeCap.round;

    final handleLightPaint = Paint()
      ..color = basketColor
      ..style = PaintingStyle.fill
      ..strokeWidth = width * 0.04
      ..strokeCap = StrokeCap.round;

    // Now draw the blue vertical part of the handle
    final handlePath = Path();

    // Start at the right end of the horizontal bar
    handlePath.moveTo(width * 0.10, height * 0.05);

    // Curve down to connect with the basket
    handlePath.quadraticBezierTo(
        width * 0.19, height * 0.05, width * 0.183, height * 0.15);

    // Draw the blue part of the handle
    canvas.drawPath(handlePath, outlinePaint);

    // First draw the light blue horizontal part of the handle
    canvas.drawLine(Offset(0, height * 0.05),
        Offset(width * 0.10, height * 0.05), handleLightPaint);

    // Draw the basket (trapezoidal shape)
    final basketPath = Path();

    // Top-left of basket
    basketPath.moveTo(width * 0.18, height * 0.15);

    // Top-right of basket (higher than left to create slant)
    basketPath.lineTo(width * 0.95, height * 0.17);

    // Bottom-right of basket
    basketPath.lineTo(width * 0.85, height * 0.65);

    // Bottom-left of basket
    basketPath.lineTo(width * 0.20, height * 0.70);

    // Close the path
    basketPath.close();

    // Fill the basket with semi-transparent color
    canvas.drawPath(basketPath, fillPaint);

    // Draw the basket outline
    canvas.drawPath(basketPath, outlinePaint);

    // Draw the diagonal slits in the basket
    for (int i = 0; i <= 4; i++) {
      final initStart = width * (0.30 + (i * 0.12));

      final startX = initStart - width * 0.02;
      final endX = initStart;

      canvas.drawLine(Offset(startX, height * 0.25),
          Offset(endX, height * 0.55), slitsPaint);
    }

    // Draw the cart frame
    final framePath = Path();

    // Start at the bottom-left of basket
    framePath.moveTo(width * 0.20, height * 0.70);

    // Curve down to the back wheel
    framePath.quadraticBezierTo(
        width * 0.09, height * 0.80, width * 0.25, height * 0.90);

    // Horizontal bar to front wheel
    framePath.lineTo(width * 0.75, height * 0.90);

    // Draw the frame
    canvas.drawPath(framePath, outlinePaint);

    // Draw the wheels
    final backWheelCenter = Offset(width * 0.25, height * 0.95);
    final frontWheelCenter = Offset(width * 0.75, height * 0.95);
    final wheelRadius = width * 0.08;
    final wheelInnerRadius = wheelRadius * 0.6;

    // Back wheel
    canvas.drawCircle(backWheelCenter, wheelRadius, wheelOutlinePaint);
    canvas.drawCircle(backWheelCenter, wheelInnerRadius, wheelCenterPaint);

    // Front wheel
    canvas.drawCircle(frontWheelCenter, wheelRadius, wheelOutlinePaint);
    canvas.drawCircle(frontWheelCenter, wheelInnerRadius, wheelCenterPaint);
  }

  @override
  bool shouldRepaint(CartPainter oldDelegate) {
    return oldDelegate.outlineColor != outlineColor ||
        oldDelegate.basketColor != basketColor ||
        oldDelegate.basketOpacity != basketOpacity ||
        oldDelegate.wheelCenterColor != wheelCenterColor;
  }
}
