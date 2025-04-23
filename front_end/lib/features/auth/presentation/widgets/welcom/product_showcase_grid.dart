import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:semo/core/presentation/navigation/router_services/route_constants.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/auth/domain/entities/welcom_entity.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_bloc.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_event.dart';
import 'package:semo/features/auth/presentation/bloc/welcome/welcome_assets_state.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
import 'package:semo/features/auth/presentation/widgets/welcom/store_showcase.dart';

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
          if (state is TaskAssetLoaded) {
            // Use the TaskAsset images from the loaded state
            return _buildTaskAssetContent(context, state.taskAsset);
          } else if (state is TaskAssetLoading || state is AllAssetsLoading) {
            // Show a loading indicator while assets are being loaded
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
    backgroundColor: Colors.white,
    textColor: Colors.black,
    padding: const EdgeInsets.all(16.0),
  );
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
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsets padding;
  final double gridSpacing;
  final double itemBorderRadius;

  const ProductShowcaseGrid({
    Key? key,
    required this.imageUrls,
    this.titleText,
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
          // Caption text at the bottom
          if (titleText != null)
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
              child: _buildCaptionText(context),
            ),
          // Overlapping cards with profile labels
          _buildOverlappingCards(imageUrls),

          // Login and Register buttons
          buildButtons(context, AppRoutes.register, AppRoutes.login,
              'Créer un compte', 'Se connecter'),
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

  /// Builds overlapping cards layout with profile labels
  Widget _buildOverlappingCards(List<String> images) {
    // Ensure we have at least 5 images
    final List<String> imagesToUse = images.length >= 5
        ? images.sublist(0, 5)
        : [...images, ...List.filled(5 - images.length, '')];

    // Sample profile images - replace with actual profile images in production
    final profileImages = [
      'https://randomuser.me/api/portraits/men/32.jpg',
      'https://randomuser.me/api/portraits/women/44.jpg',
    ];

    // Sample textimages - replace with actual textimages in production
    final textimages = ['Mr. Propre', 'Cheffe cuisinière'];

    return SizedBox(
      height: 230,
      child: Stack(
        children: [
          // Left card stack
          Positioned(
            left: 5,
            top: 40,
            child: _buildCardStack(
              mainImage: imagesToUse[4],
              backgroundImage: imagesToUse[0],
              profileImage: profileImages[0],
              textimage: textimages[0],
              angle: -5,
              mainCardColor: Colors.purple.shade100,
              stackCardColor: Colors.purple.shade200,
            ),
          ),

          // Right card stack (positioned to overlap slightly)
          Positioned(
            right: 0,
            top: 20,
            child: _buildCardStack(
              mainImage: imagesToUse[3],
              backgroundImage: imagesToUse[2],
              profileImage: profileImages[1],
              textimage: textimages[1],
              angle: 5,
              mainCardColor: Colors.orange.shade100,
              stackCardColor: Colors.orange.shade200,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a card stack with a main card and background cards
  Widget _buildCardStack({
    required String mainImage,
    required String backgroundImage,
    required String profileImage,
    required String textimage,
    required double angle,
    required Color mainCardColor,
    required Color stackCardColor,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background cards for stacked effect
        Positioned(
          left: -8,
          top: -8,
          child: Transform.rotate(
            angle: (angle - 5) * 0.0174533, // Convert degrees to radians
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: stackCardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
                image: backgroundImage.isNotEmpty
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(backgroundImage),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
          ),
        ),

        // Main card
        Transform.rotate(
          angle: angle * 0.0174533, // Convert degrees to radians
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: mainCardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
              image: mainImage.isNotEmpty
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(mainImage),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),

            // Profile label at the top of the card
            child: Align(
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
                    // TextImage text
                    Text(
                      textimage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
