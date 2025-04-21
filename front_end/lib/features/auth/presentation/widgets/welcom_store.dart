// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:semo/core/presentation/theme/responsive_theme.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/store/domain/entities/store.dart';

class StoreSection extends StatelessWidget {
  final List<StoreBrand> stores;
  final double sectionHeight;

  const StoreSection(
      {Key? key, required this.stores, required this.sectionHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) {
      return const SizedBox.shrink();
    }

    double imageSize = sectionHeight - sectionHeight * 0.2;

    return SizedBox(
      height: sectionHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: context.xs),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          final store = stores[index];
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.xs),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StoreImageButton(store: store, size: imageSize),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class StoreImageButton extends StatelessWidget {
  final StoreBrand store;
  final double size;
  static final AppLogger _logger = AppLogger();

  const StoreImageButton({
    Key? key,
    required this.store,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: store.imageLogo.isNotEmpty
          ? _buildStoreImage(context, size)
          : _buildFallbackIcon(context, size),
    );
  }

  Widget _buildStoreImage(BuildContext context, double size) {
    return Image.network(
      store.imageLogo,
      fit: BoxFit.cover,
      width: size,
      height: size,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingIndicator(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        _logger.error('Error loading store image: $error');
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
      color: context.textSecondaryColor,
    );
  }
}
