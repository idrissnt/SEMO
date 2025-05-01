import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/presentation/theme/app_dimensions.dart';

import 'package:semo/features/auth/presentation/widgets/for_welcome/styles/task_card_theme.dart';

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
    final backgroundCardLeftPosition =
        DefaultTaskCardAssets.backgroundCardLeftPosition;
    final backgroundCardTopPosition =
        DefaultTaskCardAssets.backgroundCardTopPosition;
    final backgroundCardAngleInclination =
        DefaultTaskCardAssets.backgroundCardAngleInclination;
    final angleBackgroundInclination = angle - backgroundCardAngleInclination;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background card (positioned slightly behind)
        Positioned(
          left: backgroundCardLeftPosition,
          top: backgroundCardTopPosition,
          child: Transform.rotate(
            angle: angleBackgroundInclination * DefaultTaskCardAssets.degToRad,
            child: _buildCardContainer(
              width: DefaultTaskCardAssets.cardWidth,
              height: DefaultTaskCardAssets.cardHeight,
              color: stackCardColor,
              borderRadius: DefaultTaskCardAssets.cardRadius,
              boxShadow: DefaultTaskCardAssets.getBoxShadow(isMainCard: false),
              imageUrl: backgroundImage,
            ),
          ),
        ),

        // Main card
        Transform.rotate(
          angle: angle * DefaultTaskCardAssets.degToRad,
          child: _buildCardContainer(
            width: DefaultTaskCardAssets.cardWidth,
            height: DefaultTaskCardAssets.cardHeight,
            color: mainCardColor,
            borderRadius: DefaultTaskCardAssets.cardRadius,
            boxShadow: DefaultTaskCardAssets.getBoxShadow(),
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

    final profileImageSize = AppIconSize.small;

    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: AppDimensionsWidth.xxSmall,
            vertical: AppDimensionsHeight.xxSmall),
        padding: EdgeInsets.symmetric(
            horizontal: AppDimensionsWidth.xSmall,
            vertical: AppDimensionsHeight.xxSmall),
        decoration: BoxDecoration(
          color: AppColors.primaryVariant,
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
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
              backgroundColor: AppColors.background,
              child: profileImage.isEmpty
                  ? Icon(Icons.person, size: profileImageSize)
                  : null,
            ),
            SizedBox(width: AppDimensionsWidth.xxSmall),
            // Profile title
            Text(
              labelText,
              style: TextStyle(
                fontSize: AppFontSize.small,
                color: AppColors.textSecondaryColor,
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
