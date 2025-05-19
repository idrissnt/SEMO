import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/search_bar_widget.dart';
import 'package:semo/features/order/presentation/widgets/app_bar/utils/action_icon_button.dart';
import 'package:semo/features/store/domain/entities/store.dart';
import 'package:semo/features/store/presentation/animations/animated_gradient_background.dart';

final Logger _logger = Logger('StoreShopAppBar');

class StoreShopAppBar extends StatefulWidget {
  final StoreBrand store;
  final ScrollController scrollController;
  final bool isScrolled;
  final double scrollProgress;
  final String backRoute;

  const StoreShopAppBar({
    Key? key,
    required this.store,
    required this.scrollController,
    required this.isScrolled,
    required this.scrollProgress,
    required this.backRoute,
  }) : super(key: key);

  @override
  State<StoreShopAppBar> createState() => _StoreShopAppBarState();
}

class _StoreShopAppBarState extends State<StoreShopAppBar>
    with TickerProviderStateMixin {
  /// Animation controller for gradient animation
  late AnimationController _gradientAnimationController;

  @override
  void initState() {
    super.initState();

    // Initialize gradient animation controller
    _gradientAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100), // Control animation speed here
    )..repeat(); // Makes the animation loop continuously
  }

  @override
  void dispose() {
    _gradientAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Calculate height based on scroll progress for smooth transition
    final appBarHeight =
        statusBarHeight + 160.0 - (100.0 * widget.scrollProgress);

    // Calculate search bar position and width based on scroll progress
    final searchBarLeftPosition = 16.0 + (50.0 * widget.scrollProgress);
    const searchBarRightPosition = 16.0;

    return SizedBox(
      height: appBarHeight,
      child: AnimatedGradientBackground(
        height: statusBarHeight + 160,
        child: Stack(
          children: [
            // Store banner image with rounded corners and white border
            Positioned(
              top: statusBarHeight + 10,
              left: 0,
              right: 0,
              child: Opacity(
                // Fade out based on scroll progress
                opacity: 1.0 - (widget.scrollProgress * 2).clamp(0.0, 1.0),
                child: Center(
                  child: Container(
                    // Smoothly scale down based on scroll progress
                    width: 120 * (1.0 - widget.scrollProgress.clamp(0.0, 1.0)),
                    height: 80 * (1.0 - widget.scrollProgress.clamp(0.0, 1.0)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.store.imageBanner,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          _logger.log(Level.SEVERE, 'Error loading image',
                              error, stackTrace);
                          return const Icon(Icons.error);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Search bar with dynamic positioning and width
            Positioned(
              bottom: 12,
              left: searchBarLeftPosition,
              right: searchBarRightPosition,
              child: SearchBarWidget(
                isScrolled: widget.isScrolled,
                searchBarColor: Colors.white,
                iconColor: Colors.black,
                hintColor: Colors.black,
              ),
            ),

            // Back button - always visible
            Positioned(
              top: statusBarHeight + 12,
              left: 16,
              child: _buildActionIcons(
                onPressed: () {
                  // Use GoRouter to navigate to the order screen
                  context.go(widget.backRoute);
                },
                icon: CupertinoIcons.xmark_circle_fill,
                iconColor: Colors.white,
                backgroundColor: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
            ),

            // Info and Add Person buttons with opacity based on scroll progress
            Positioned(
              top: statusBarHeight + 12,
              right: 16,
              child: Opacity(
                opacity: 1.0 - widget.scrollProgress,
                child: Row(
                  children: [
                    _buildActionIcons(
                      onPressed: () {},
                      icon: CupertinoIcons.info,
                      iconColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    const SizedBox(width: 10),
                    _buildActionIcons(
                      onPressed: () {},
                      icon: CupertinoIcons.person_add,
                      iconColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcons({
    required VoidCallback onPressed,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    BorderRadius? borderRadius,
    double? size,
  }) {
    return Container(
      padding: const EdgeInsets.all(0),
      height: 35,
      width: 35,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: ActionIconButton(
        icon: icon,
        color: iconColor,
        onPressed: onPressed,
        size: size ?? 24,
      ),
    );
  }
}
