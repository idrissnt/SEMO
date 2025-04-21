// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:semo/core/utils/logger.dart';

import '../../../../core/presentation/theme/responsive_theme.dart';
import '../../../store/domain/entities/store.dart';

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

    return SizedBox(
      height: sectionHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.xs),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          final store = stores[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: context.xs),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StoreImageButton(store: store),
                SizedBox(height: context.m),
                Text(
                  store.name,
                  style: context.appBarTitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StoreImageButton extends StatelessWidget {
  final StoreBrand store;
  static final AppLogger _logger = AppLogger();

  const StoreImageButton({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = context.responsiveItemSize(100);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(width: 3.5),
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 1, 60, 108),
            blurRadius: 2,
            spreadRadius: 0.5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: store.imageLogo.isNotEmpty
          ? _buildStoreImage(context, size)
          : _buildFallbackIcon(context, size),
    );
  }

  Widget _buildStoreImage(BuildContext context, double size) {
    return ClipOval(
      child: Image.network(
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
      ),
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
      size: size * 0.4,
      color: context.textSecondaryColor,
    );
  }
}
