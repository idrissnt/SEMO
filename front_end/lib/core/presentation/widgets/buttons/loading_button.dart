import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:semo/core/presentation/widgets/buttons/animated_button.dart';

/// A button that shows a loading indicator when in loading state
///
/// This button extends the functionality of AnimatedButton by adding
/// a loading state that displays a CircularProgressIndicator
class LoadingButton extends StatelessWidget {
  /// The callback to execute when the button is pressed
  final VoidCallback onPressed;

  /// The child widget to display when not in loading state
  final Widget child;

  /// The style of the button
  final ButtonStyle style;

  /// Whether the button is in loading state
  final bool isLoading;

  /// The color of the splash effect when the button is pressed
  final Color splashColor;

  /// The color of the highlight effect
  final Color highlightColor;

  /// The color of the shadow effect
  final Color boxShadowColor;

  /// Whether to enable haptic feedback when the button is pressed
  final bool enableHapticFeedback;

  /// The duration of the animation
  final Duration animationDuration;

  const LoadingButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.style,
    required this.isLoading,
    required this.splashColor,
    required this.highlightColor,
    required this.boxShadowColor,
    this.enableHapticFeedback = true,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // When loading, disable the button's onPressed function
    final effectiveOnPressed = isLoading ? () {} : onPressed;

    return AnimatedButton(
      onPressed: effectiveOnPressed,
      style: style,
      splashColor: splashColor,
      highlightColor: highlightColor,
      boxShadowColor: boxShadowColor,
      enableHapticFeedback: enableHapticFeedback && !isLoading,
      animationDuration: animationDuration,
      child: isLoading ? _buildLoadingContent() : child,
    );
  }

  /// Builds the loading indicator
  Widget _buildLoadingContent() {
    return SizedBox(
      height: 24.h,
      width: 24.w,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          style.foregroundColor?.resolve({}) ?? Colors.white,
        ),
      ),
    );
  }
}
