import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/components/auth_buttons.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/components/task/task_card_layout.dart';

/// This widget creates a visually appealing showcase of products using a staggered grid layout,
/// similar to a masonry grid, with a text caption at the bottom.
class TaskCardShowcaseGrid extends StatelessWidget {
  // Core properties for task card display
  final List<Map<String, String>> mainCards;
  final List<String> backgroundImages;
  final String titleText;

  const TaskCardShowcaseGrid({
    Key? key,
    required this.titleText,
    required this.mainCards,
    required this.backgroundImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: context.xxLargeHeight,
          bottom: context.xxLargeHeight,
          left: context.xlWidth,
          right: context.lWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title text
          _buildCaptionText(context),

          // Task cards display
          CardLayout(
            mainCards: mainCards,
            backgroundImages: backgroundImages,
          ),

          // Auth buttons
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
