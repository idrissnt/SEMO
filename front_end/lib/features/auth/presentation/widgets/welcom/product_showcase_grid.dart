import 'package:flutter/material.dart';
import 'package:semo/core/presentation/navigation/router_services/route_constants.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/components/card_layout.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/components/task_card_builder.dart'
    show TaskCardBuilder;
import 'package:semo/features/auth/presentation/widgets/welcom/store_showcase.dart';

/// This widget creates a visually appealing showcase of products using a staggered grid layout,
/// similar to a masonry grid, with a text caption at the bottom.
class ProductShowcaseGrid extends StatelessWidget {
  // Core properties for task card display
  final List<Map<String, String>>? mainCards;
  final List<String>? backgroundImages;
  final String? titleText;

  // Legacy property - kept for backward compatibility
  final List<String> imageUrls;

  // Styling properties
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsets padding;

  const ProductShowcaseGrid({
    Key? key,
    required this.imageUrls,
    this.titleText,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.all(16.0),
    this.mainCards,
    this.backgroundImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title text
          if (titleText != null && titleText!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 16.0),
              child: _buildCaptionText(context),
            ),

          // Task cards display
          CardLayout(
            mainCards: mainCards,
            backgroundImages: backgroundImages,
            imageUrls: imageUrls,
          ),

          // Action buttons
          // const SizedBox(height: 16),
          buildButtons(context, AppRoutes.register, AppRoutes.login,
              'Créer un compte', 'Se connecter'),
        ],
      ),
    );
  }

  /// Builds the caption text section with gradient text
  Widget _buildCaptionText(BuildContext context) {
    return Text(
      textAlign: TextAlign.center,
      titleText!,
      style: context.headline1,
    );
  }
}

/// Entry point function to build a task card
Widget buildTaskCard(BuildContext context) {
  // Import the TaskCardBuilder to maintain backward compatibility
  return TaskCardBuilder.build(context);
}
