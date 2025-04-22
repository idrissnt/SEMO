import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/domain/entities/welcom_entity.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_event.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_state.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';

final AppLogger logger = AppLogger();

/// Builds a product showcase card using the staggered grid layout
Widget buildTaskCard(BuildContext context) {
  return Card(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(33.0)),
    child: SizedBox(
      width: context.responsiveItemSize(300),
      child: BlocBuilder<WelcomeAssetsBloc, WelcomeAssetsState>(
        builder: (context, state) {
          logger.info('The sate kjubf State: $state');
          if (state is TaskAssetLoaded) {
            // Use the TaskAsset images from the loaded state
            logger.info('Task asset loaded successfully');
            return _buildTaskAssetContent(context, state.taskAsset);
          } else if (state is TaskAssetLoading || state is AllAssetsLoading) {
            // Show a loading indicator while assets are being loaded
            logger.info('Task asset loading...');
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue),
                  SizedBox(height: 16),
                  Text('Loading assets...',
                      style: TextStyle(color: Colors.black)),
                ],
              ),
            );
          } else {
            // Show a debug message with the current state for troubleshooting
            // and retry loading in the background
            Future.delayed(const Duration(seconds: 3), () {
              if (context.mounted) {
                context
                    .read<WelcomeAssetsBloc>()
                    .add(const LoadTaskAssetEvent());
              }
            });

            // Create a placeholder grid with empty containers
            return ProductShowcaseGrid(
              imageUrls: List.generate(5, (_) => ''),
              titleText: 'Loading content...',
              backgroundColor: Colors.white,
              textColor: Colors.black,
              padding: const EdgeInsets.all(16.0),
            );
          }
        },
      ),
    ),
  );
}

/// Builds content when task asset is loaded
Widget _buildTaskAssetContent(BuildContext context, TaskAsset taskAsset) {
  final List<String> taskImages = [
    taskAsset.firstImage,
    taskAsset.secondImage,
    taskAsset.thirdImage,
    taskAsset.fourthImage,
    taskAsset.fifthImage,
  ];

  logger.info('Task images: $taskImages');

  return ProductShowcaseGrid(
    imageUrls: taskImages,
    titleText: taskAsset.titleOne,
    subtitleText: taskAsset.titleTwo,
    backgroundColor: Colors.white,
    textColor: Colors.black,
    padding: const EdgeInsets.all(16.0),
  );
}

/// A simple class to define the pattern for a grid tile
class GridTilePattern {
  final int crossAxis;
  final int mainAxis;

  const GridTilePattern({required this.crossAxis, required this.mainAxis});
}

/// Animated gradient text widget
class AnimatedGradientText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  const AnimatedGradientText({
    Key? key,
    required this.text,
    required this.fontSize,
    this.fontWeight = FontWeight.normal,
  }) : super(key: key);

  @override
  State<AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: const [
              Colors.blue,
              Colors.purple,
              Colors.pink,
              Colors.purple,
              Colors.blue
            ],
            stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            transform: GradientRotation(_controller.value * 2 * 3.14159),
          ).createShader(bounds),
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

/// This widget creates a visually appealing showcase of products using a staggered grid layout,
/// similar to a masonry grid, with a text caption at the bottom.
class ProductShowcaseGrid extends StatelessWidget {
  final List<String> imageUrls;

  final String? titleText;
  final String? subtitleText;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsets padding;
  final double gridSpacing;
  final double itemBorderRadius;

  const ProductShowcaseGrid({
    Key? key,
    required this.imageUrls,
    this.titleText,
    this.subtitleText,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.all(16.0),
    this.gridSpacing = 8.0,
    this.itemBorderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Column(
        children: [
          // Staggered grid of product images
          _buildStaggeredGrid(imageUrls),

          // Caption text at the bottom
          if (titleText != null || subtitleText != null)
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
              child: _buildCaptionText(context),
            ),
        ],
      ),
    );
  }

  /// Builds the caption text section with gradient text
  Widget _buildCaptionText(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (titleText != null)
          _buildGradientText(
            titleText!,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        if (subtitleText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: _buildGradientText(
              subtitleText!,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  /// Helper method to create animated gradient text
  Widget _buildGradientText(
    String text, {
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return AnimatedGradientText(
      text: text,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  /// Builds the staggered grid layout for product images
  Widget _buildStaggeredGrid(List<String> images) {
    const double gridSpacing = 8.0;

    // logger.info('Building staggered grid with ${images.length} images');
    // logger.info('Images: $images');

    // Ensure we have at least 5 images for the layout
    final List<String> imagesToUse = images.length >= 5
        ? images.sublist(0, 5)
        : [...images, ...List.filled(5 - images.length, '')];

    // logger.info('Using images: $imagesToUse');
    // Define a more type-safe approach with a custom class
    final patterns = [
      const GridTilePattern(
          crossAxis: 2, mainAxis: 2), // Large image (top-left)
      const GridTilePattern(crossAxis: 1, mainAxis: 1), // Top-right image
      const GridTilePattern(crossAxis: 1, mainAxis: 1), // Middle-right image
      const GridTilePattern(crossAxis: 1, mainAxis: 1), // Bottom-left image
      const GridTilePattern(crossAxis: 1, mainAxis: 1), // Bottom-middle image
    ];

    // Wrap in a SizedBox with fixed height to prevent layout issues
    return SizedBox(
      height: 300, // Fixed height to prevent infinite height constraint
      child: StaggeredGrid.count(
        crossAxisCount: 3,
        mainAxisSpacing: gridSpacing,
        crossAxisSpacing: gridSpacing,
        children: List.generate(5, (index) {
          final pattern = patterns[index];
          return StaggeredGridTile.count(
            crossAxisCellCount: pattern.crossAxis,
            mainAxisCellCount: pattern.mainAxis,
            child: _buildGridItem(imagesToUse[index], index),
          );
        }),
      ),
    );
  }

  /// Builds an individual grid item with optimized image loading
  Widget _buildGridItem(String imageUrl, int index) {
    if (imageUrl.isEmpty) {
      // Placeholder for empty image URLs
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(itemBorderRadius),
        ),
      );
    }

    // Network image with caching and optimizations
    return Hero(
      tag: 'product_image_$index', // Enable hero animations if needed
      child: ClipRRect(
        borderRadius: BorderRadius.circular(itemBorderRadius),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 200),
          memCacheHeight: 500, // Optimize memory usage
          placeholder: (context, url) => Container(color: Colors.grey[800]),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[800],
            child: const Icon(Icons.error, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
