import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:semo/features/auth/presentation/widgets/welcome/styles/task_card_theme.dart';

/// A component that builds a stack of cards with a main card and background card
class StackOfCards extends StatelessWidget {
  final String mainImage;
  final String backgroundImage;
  final String profileImage;
  final String profileTitle;
  final double angle;
  final Color mainCardColor;
  final Color stackCardColor;

  const StackOfCards({
    Key? key,
    required this.mainImage,
    required this.backgroundImage,
    required this.profileImage,
    required this.profileTitle,
    required this.angle,
    required this.mainCardColor,
    required this.stackCardColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background card (positioned slightly behind)
        Positioned(
          left: -8,
          top: -8,
          child: Transform.rotate(
            angle: (angle - 5) * DefaultAssets.degToRad,
            child: _buildCardContainer(
              width: DefaultAssets.cardWidth,
              height: DefaultAssets.cardHeight,
              color: stackCardColor,
              borderRadius: DefaultAssets.cardRadius,
              boxShadow: DefaultAssets.getBoxShadow(isMainCard: false),
              imageUrl: backgroundImage,
            ),
          ),
        ),

        // Main card
        Transform.rotate(
          angle: angle * DefaultAssets.degToRad,
          child: _buildCardContainer(
            width: DefaultAssets.cardWidth,
            height: DefaultAssets.cardHeight,
            color: mainCardColor,
            borderRadius: DefaultAssets.cardRadius,
            boxShadow: DefaultAssets.getBoxShadow(),
            imageUrl: mainImage,
            child: _buildProfileLabel(profileImage, profileTitle),
          ),
        ),
      ],
    );
  }

  /// Builds the profile label that appears on cards
  Widget? _buildProfileLabel(String profileImage, String labelText) {
    if (profileImage.isEmpty) return null;

    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.shade500,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile image
            CircleAvatar(
              radius: 12,
              backgroundImage: CachedNetworkImageProvider(profileImage),
            ),
            const SizedBox(width: 4),
            // Profile title
            Text(
              labelText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build card containers with consistent styling
  Widget _buildCardContainer({
    required double width,
    required double height,
    required Color color,
    required double borderRadius,
    required BoxShadow boxShadow,
    required String imageUrl,
    Widget? child,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [boxShadow],
        image: imageUrl.isNotEmpty
            ? DecorationImage(
                image: CachedNetworkImageProvider(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: child,
    );
  }
}
