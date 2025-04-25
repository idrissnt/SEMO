import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/theme_services/app_colors.dart';
import 'package:semo/core/utils/logger.dart';

class StoreImage extends StatelessWidget {
  final String storeLogo;
  final double size;
  static final AppLogger _logger = AppLogger();

  const StoreImage({
    Key? key,
    required this.storeLogo,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Build store image container
    return SizedBox(
      width: size,
      height: size,
      child: storeLogo.isNotEmpty
          ? _buildStoreImage(context, size)
          : _buildFallbackIcon(context, size),
    );
  }

  Widget _buildStoreImage(BuildContext context, double size) {
    // Build store image
    return Image.network(
      storeLogo,
      fit: BoxFit.cover,
      width: size,
      height: size,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        // Build loading indicator
        return _buildLoadingIndicator(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        _logger.error('Error loading store image: $error');
        // Build fallback icon
        return _buildFallbackIcon(context, size);
      },
    );
  }

  Widget _buildLoadingIndicator(ImageChunkEvent loadingProgress) {
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  }

  Widget _buildFallbackIcon(BuildContext context, double size) {
    return Icon(
      Icons.store,
      size: size,
      color: AppColors.textSecondaryColor,
    );
  }
}
