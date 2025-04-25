import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
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
    final cardLeftPosition = context.getResponsiveWidthValue(-7);
    final cardTopPosition = context.getResponsiveHeightValue(-7);
    final angleBackgroundInclination =
        context.getResponsiveWidthValue(angle - 5);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background card (positioned slightly behind)
        Positioned(
          left: cardLeftPosition,
          top: cardTopPosition,
          child: Transform.rotate(
            angle: angleBackgroundInclination * DefaultAssets.degToRad,
            child: _buildCardContainer(
              width: DefaultAssets.cardWidth(context),
              height: DefaultAssets.cardHeight(context),
              color: stackCardColor,
              borderRadius: DefaultAssets.cardRadius(context),
              boxShadow: DefaultAssets.getBoxShadow(isMainCard: false),
              imageUrl: backgroundImage,
            ),
          ),
        ),

        // Main card
        Transform.rotate(
          angle: angle * DefaultAssets.degToRad,
          child: _buildCardContainer(
            width: DefaultAssets.cardWidth(context),
            height: DefaultAssets.cardHeight(context),
            color: mainCardColor,
            borderRadius: DefaultAssets.cardRadius(context),
            boxShadow: DefaultAssets.getBoxShadow(),
            imageUrl: mainImage,
            child: _buildProfileLabel(context, profileImage, profileTitle),
          ),
        ),
      ],
    );
  }

  /// Builds the profile label that appears on cards
  Widget? _buildProfileLabel(
      BuildContext context, String profileImage, String labelText) {
    if (profileImage.isEmpty) return null;

    final profileImageSize = context.iconSizeSmallWidth;

    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: context.xsWidth, vertical: context.extraSmallHeight),
        padding: EdgeInsets.symmetric(
            horizontal: context.sWidth, vertical: context.extraSmallHeight),
        decoration: BoxDecoration(
          color: context.primaryVariantColor,
          borderRadius: BorderRadius.circular(context.borderRadiusLargeWidth),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile image
            CircleAvatar(
              radius: profileImageSize,
              backgroundImage: profileImage.isNotEmpty
                  ? CachedNetworkImageProvider(profileImage)
                  : null,
              backgroundColor: context.backgroundColor,
              child: profileImage.isEmpty
                  ? Icon(Icons.person, size: profileImageSize)
                  : null,
            ),
            SizedBox(width: context.xsWidth),
            // Profile title
            Text(
              labelText,
              style: context.bodyMedium.copyWith(
                color: context.textSecondaryColor,
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
