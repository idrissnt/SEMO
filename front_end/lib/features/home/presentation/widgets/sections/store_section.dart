// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/features/store/domain/entities/store.dart';

class StoreSection extends StatelessWidget {
  final String title;
  final List<StoreBrand> stores;

  final AppLogger _logger = AppLogger();

  StoreSection({
    Key? key,
    required this.title,
    required this.stores,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) {
      return SizedBox.shrink();
    }

    const double storeWidth = 90;
    const double sectionHeight = 140;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(
          height: sectionHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate total width of all items
              final totalItemWidth = (storeWidth + 16) *
                  stores.length; // width + horizontal margin
              final availableWidth = constraints.maxWidth;

              // Only center if all items can fit in the available width
              final shouldCenter = totalItemWidth < availableWidth;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: shouldCenter
                      ? (availableWidth - totalItemWidth) / 2 // Center padding
                      : 4, // Default padding
                ),
                itemCount: stores.length,
                itemBuilder: (context, index) {
                  final store = stores[index];
                  return Container(
                    width: storeWidth,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StoreImageButton(
                          size: storeWidth,
                          store: store,
                          onTap: () {
                            _logger.info('Navigating to store: ${store.name}');
                            context.go('/store/${store.id}');
                          },
                        ),
                        SizedBox(height: 8),
                        Text(
                          store.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class StoreImageButton extends StatefulWidget {
  final double size;
  final StoreBrand store;
  final VoidCallback onTap;

  const StoreImageButton({
    Key? key,
    required this.size,
    required this.store,
    required this.onTap,
  }) : super(key: key);

  @override
  State<StoreImageButton> createState() => _StoreImageButtonState();
}

class _StoreImageButtonState extends State<StoreImageButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: _buildGradientContainer(
        InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(widget.size / 2),
          child: widget.store.imageLogo.isNotEmpty
              ? _buildNetworkImage()
              : _buildStorePlaceholder(),
        ),
      ),
    );
  }

  // Helper method to build the container with gradient and shadow
  Widget _buildGradientContainer(Widget child) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.storeCardBorderColor,
          width: 2,
        ),
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.storeCardShadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // Helper method to handle tap animation
  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse().then((_) {
        // widget.onTap();
      });
    });
  }

  // Helper method to build the network image with loading and error handling
  Widget _buildNetworkImage() {
    return ClipOval(
      child: Image.network(
        widget.store.imageLogo,
        height: widget.size,
        width: widget.size,
        fit: BoxFit.cover,
        loadingBuilder: _buildLoadingIndicator,
        errorBuilder: _buildErrorWidget,
      ),
    );
  }

  // Helper method to build the store icon placeholder
  Widget _buildStorePlaceholder() {
    return Container(
      height: widget.size,
      width: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
      ),
      child: Icon(
        Icons.store,
        size: widget.size * 0.5,
        color: AppColors.textSecondaryColor,
      ),
    );
  }

  // Helper method for loading indicator
  Widget _buildLoadingIndicator(
      BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) return child;

    return Container(
      height: widget.size,
      width: widget.size,
      color: AppColors.surface,
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // Helper method for error handling
  Widget _buildErrorWidget(
      BuildContext context, Object error, StackTrace? stackTrace) {
    final logger = AppLogger();
    logger.error('Error loading store image: $error');
    return _buildStorePlaceholder();
  }
}
