import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/components/auth_buttons.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/components/card_layout.dart';

/// This widget creates a visually appealing showcase of products using a staggered grid layout,
/// similar to a masonry grid, with a text caption at the bottom.
class TaskCardShowcaseGrid extends StatelessWidget {
  // Core properties for task card display
  final List<Map<String, String>> mainCards;
  final List<String> backgroundImages;
  final String titleText;

  // Styling properties
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsets padding;

  const TaskCardShowcaseGrid({
    Key? key,
    required this.titleText,
    required this.backgroundColor,
    required this.textColor,
    required this.padding,
    required this.mainCards,
    required this.backgroundImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title text
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 16.0),
            child: _buildCaptionText(context),
          ),

          // Task cards display
          CardLayout(
            mainCards: mainCards,
            backgroundImages: backgroundImages,
          ),

          // Action buttons
          const AuthButtons(),
        ],
      ),
    );
  }

  /// Builds the caption text section with gradient text
  Widget _buildCaptionText(BuildContext context) {
    return Text(
      textAlign: TextAlign.center,
      titleText,
      style: context.headline1,
    );
  }
}
