import 'package:flutter/material.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/components/task_card_stack.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/styles/card_theme.dart';

/// A component that handles the layout of task cards
class CardLayout extends StatelessWidget {
  final List<Map<String, String>>? mainCards;
  final List<String>? backgroundImages;
  final List<String> imageUrls;

  const CardLayout({
    Key? key,
    required this.mainCards,
    required this.backgroundImages,
    required this.imageUrls,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildPositionedCard(0),
          _buildPositionedCard(1),
        ],
      ),
    );
  }

  /// Builds a positioned card with the appropriate theme and data
  Widget _buildPositionedCard(int position) {
    final cardData = _getCardData(position);
    final theme = DefaultAssets.cardThemes[position];
    
    return Positioned(
      // Position based on card theme
      left: theme.position == CardPosition.left ? 0 : null,
      right: theme.position == CardPosition.right ? 0 : null,
      top: 20,
      child: TaskCardStack(
        mainImage: cardData['mainImage'] as String,
        backgroundImage: cardData['backgroundImage'] as String,
        profileImage: cardData['profileImage'] as String,
        profileTitle: cardData['profileTitle'] as String,
        angle: theme.angle,
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
        'mainImage': mainCards![position]['mainImage'] ?? DefaultAssets.defaultImagePath,
        'backgroundImage': backgroundImages![position],
        'profileImage': mainCards![position]['profileImage'] ?? DefaultAssets.defaultImagePath,
        'profileTitle': mainCards![position]['profileTitle'] ?? DefaultAssets.defaultTitle,
      };
    } else {
      // Use fallback data
      return _createFallbackCardData(imageUrls, position);
    }
  }

  /// Creates fallback card data when organized data is not available
  Map<String, String> _createFallbackCardData(List<String> images, int position) {
    // Define image indices based on position
    final imageIndices = [
      [0, 4, 1], // Left card [mainImage, backgroundImage, profileImage]
      [3, 2, 1], // Right card [mainImage, backgroundImage, profileImage]
    ];
    
    final indices = position < imageIndices.length ? imageIndices[position] : imageIndices[0];
    
    return {
      'mainImage': images.length > indices[0] ? images[indices[0]] : '',
      'backgroundImage': images.length > indices[1] ? images[indices[1]] : '',
      'profileImage': images.length > indices[2] ? images[indices[2]] : '',
      'profileTitle': '${DefaultAssets.defaultTitle} ${position + 1}',
    };
  }
}
