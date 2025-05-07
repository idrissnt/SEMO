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
    this.basketColor = const Color(0xFF8ECAE6), // Light blue
    this.basketOpacity = 0.7,
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

    final handleEndPaint = Paint()
      ..color = basketColor
      ..style = PaintingStyle.fill;

    //
    // Draw the basket (trapezoidal shape)
    final basketPath = Path();

    // Top-left of basket
    basketPath.moveTo(width * 0.25, height * 0.25);

    // Top-right of basket (higher than left to create slant)
    basketPath.lineTo(width * 0.85, height * 0.15);

    // Bottom-right of basket
    basketPath.lineTo(width * 0.75, height * 0.55);

    // Bottom-left of basket
    basketPath.lineTo(width * 0.15, height * 0.55);

    // Close the path
    basketPath.close();

    // Fill the basket with semi-transparent color
    canvas.drawPath(basketPath, fillPaint);

    // Draw the basket outline
    canvas.drawPath(basketPath, outlinePaint);

    // Draw the diagonal slits in the basket
    for (int i = 1; i <= 5; i++) {
      final startX = width * (0.25 + (i * 0.1));
      final endX = startX - width * 0.03;

      canvas.drawLine(
          Offset(startX, height * 0.2), Offset(endX, height * 0.5), slitsPaint);
    }

    // Draw the cart frame
    final framePath = Path();

    // Start at the bottom-left of basket
    framePath.moveTo(width * 0.15, height * 0.55);

    // Curve down to the back wheel
    framePath.quadraticBezierTo(
        width * 0.1, height * 0.65, width * 0.25, height * 0.75);

    // Horizontal bar to front wheel
    framePath.lineTo(width * 0.65, height * 0.75);

    // Draw the frame
    canvas.drawPath(framePath, outlinePaint);

    // Draw the handle
    final handlePath = Path();

    // Start at top-left of basket
    handlePath.moveTo(width * 0.25, height * 0.25);

    // Horizontal bar of handle
    handlePath.lineTo(width * 0.1, height * 0.25);

    // Draw the handle
    canvas.drawPath(handlePath, outlinePaint);

    // Draw the handle end (circular grip)
    canvas.drawCircle(
        Offset(width * 0.1, height * 0.25), width * 0.04, handleEndPaint);
    canvas.drawCircle(
        Offset(width * 0.1, height * 0.25), width * 0.04, outlinePaint);

    // Draw the wheels
    final backWheelCenter = Offset(width * 0.25, height * 0.8);
    final frontWheelCenter = Offset(width * 0.65, height * 0.8);
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

/// Extension to create a darker version of a color
extension ColorExtension on Color {
  Color darker([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }
}
