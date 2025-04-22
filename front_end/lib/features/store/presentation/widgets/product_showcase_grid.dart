import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A widget that displays a staggered grid of product images with a caption.
/// 
/// This widget creates a visually appealing showcase of products using a staggered grid layout,
/// similar to a masonry grid, with a text caption at the bottom.
class ProductShowcaseGrid extends StatelessWidget {
  /// List of image URLs or asset paths to display in the grid
  final List<String> imageUrls;
  
  /// Whether the images are from network URLs (true) or local assets (false)
  final bool isNetworkImage;
  
  /// Optional title text to display at the bottom of the grid
  final String? titleText;
  
  /// Optional subtitle text to display below the title
  final String? subtitleText;
  
  /// Optional additional text to display below the subtitle
  final String? additionalText;
  
  /// Background color for the entire widget
  final Color backgroundColor;
  
  /// Text color for the caption
  final Color textColor;
  
  /// Padding around the entire widget
  final EdgeInsetsGeometry padding;
  
  /// Spacing between grid items
  final double gridSpacing;
  
  /// Border radius for grid items
  final double itemBorderRadius;

  const ProductShowcaseGrid({
    Key? key,
    required this.imageUrls,
    this.isNetworkImage = false,
    this.titleText,
    this.subtitleText,
    this.additionalText,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.all(16.0),
    this.gridSpacing = 8.0,
    this.itemBorderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: padding,
      child: Column(
        children: [
          // Staggered grid of product images
          _buildStaggeredGrid(),
          
          // Caption text at the bottom
          if (titleText != null || subtitleText != null || additionalText != null)
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
              child: Column(
                children: [
                  if (titleText != null)
                    Text(
                      titleText!,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  if (subtitleText != null)
                    Text(
                      subtitleText!,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  if (additionalText != null)
                    Text(
                      additionalText!,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the staggered grid layout for product images
  Widget _buildStaggeredGrid() {
    // Ensure we have at least 6 images for the layout
    final List<String> images = imageUrls.length >= 6 
        ? imageUrls.sublist(0, 6) 
        : [...imageUrls, ...List.filled(6 - imageUrls.length, '')];
    
    return StaggeredGrid.count(
      crossAxisCount: 3,
      mainAxisSpacing: gridSpacing,
      crossAxisSpacing: gridSpacing,
      children: [
        // Large image (top-left)
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 2,
          child: _buildGridItem(images[0], 0),
        ),
        // Top-right image
        StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1,
          child: _buildGridItem(images[1], 1),
        ),
        // Middle-right image
        StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1,
          child: _buildGridItem(images[2], 2),
        ),
        // Bottom-left image
        StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1,
          child: _buildGridItem(images[3], 3),
        ),
        // Bottom-middle image
        StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1,
          child: _buildGridItem(images[4], 4),
        ),
        // Bottom-right image
        StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1,
          child: _buildGridItem(images[5], 5),
        ),
      ],
    );
  }

  /// Builds an individual grid item with proper image loading and error handling
  Widget _buildGridItem(String imageUrl, int index) {
    // If the image URL is empty (for placeholder cases), show an empty container
    if (imageUrl.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(itemBorderRadius),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(itemBorderRadius),
      child: isNetworkImage
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            )
          : Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            ),
    );
  }
}
