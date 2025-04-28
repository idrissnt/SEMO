import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:semo/features/auth/presentation/widgets/shared/animated_button.dart';

/// A button that shows a loading indicator when in loading state
/// Extends the functionality of AnimatedButton to handle loading states
class LoadingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle style;
  final bool isLoading;
  final Color splashColor;
  final Color highlightColor;
  final Color boxShadowColor;
  final bool enableHapticFeedback;
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

  /// Builds the loading indicator without text
  Widget _buildLoadingContent() {
    return SizedBox(
      width: 24.r,
      height: 24.r,
      child: CircularProgressIndicator(
        strokeWidth: 2.5.r,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}
