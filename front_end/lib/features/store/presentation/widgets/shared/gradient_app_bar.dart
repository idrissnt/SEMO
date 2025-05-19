import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/store/presentation/animations/animated_gradient_background.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final double height;
  final List<Color>? gradientColors;
  final bool showBackButton;
  final Function(String) onQueryChanged;

  const GradientAppBar({
    Key? key,
    required this.title,
    this.actions,
    required this.height,
    this.gradientColors,
    required this.showBackButton,
    required this.onQueryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      height: height,
      colors: gradientColors,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: showBackButton ? 0 : 16.0,
            right: 16.0,
          ),
          child: Row(
            children: [
              // Back button if needed
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),

              // Title (usually search bar)
              Expanded(child: title),

              // Optional actions
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
