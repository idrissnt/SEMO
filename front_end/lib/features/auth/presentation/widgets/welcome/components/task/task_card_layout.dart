import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/components/task/task_card_stack.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/styles/task_card_theme.dart';

/// A component that handles the layout of task cards
class CardLayout extends StatelessWidget {
  final List<Map<String, String>>? mainCards;
  final List<String>? backgroundImages;

  const CardLayout({
    Key? key,
    required this.mainCards,
    required this.backgroundImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.getResponsiveHeightValue(220),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 0 = left
          _buildPositionedCard(context, 0),
          // 1 = right
          _buildPositionedCard(context, 1),
        ],
      ),
    );
  }

  /// Builds a positioned card with the appropriate theme and data
  Widget _buildPositionedCard(BuildContext context, int position) {
    final cardData = _getCardData(position);
    final theme = DefaultAssets.cardThemes[position];
    final leftPosition = context.getResponsiveWidthValue(18);
    final rightPosition = context.getResponsiveWidthValue(5);
    final topPosition = context.getResponsiveHeightValue(25);
    final angleInclination = context.getResponsiveWidthValue(theme.angle);

    return Positioned(
      // Position based on card theme
      left: theme.position == CardPosition.left ? leftPosition : null,
      right: theme.position == CardPosition.right ? rightPosition : null,
      top: topPosition,
      child: StackOfCards(
        mainImage: cardData['mainImage'] as String,
        backgroundImage: cardData['backgroundImage'] as String,
        profileImage: cardData['profileImage'] as String,
        profileTitle: cardData['profileTitle'] as String,
        angle: angleInclination,
        mainCardColor: theme.mainColor,
        stackCardColor: theme.stackColor,
      ),
    );
  }

  /// Gets card data with fallback handling
  Map<String, String> _getCardData(int position) {
    // Check if we have organized data
    final bool hasOrganizedData = mainCards != null &&
        mainCards!.length > position &&
        backgroundImages != null &&
        backgroundImages!.length > position;

    if (hasOrganizedData) {
      return {
        'mainImage': mainCards![position]['mainImage'] ?? '',
        'backgroundImage': backgroundImages![position],
        'profileImage': mainCards![position]['profileImage'] ?? '',
        'profileTitle':
            mainCards![position]['profileTitle'] ?? DefaultAssets.defaultTitle,
      };
    } else {
      // Use fallback data
      return _createFallbackCardData(position);
    }
  }

  /// Creates fallback card data when organized data is not available
  Map<String, String> _createFallbackCardData(int position) {
    return {
      'mainImage': '',
      'backgroundImage': '',
      'profileImage': '',
      'profileTitle': '${DefaultAssets.defaultTitle} ${position + 1}',
    };
  }
}
