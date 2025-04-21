// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:semo/core/utils/logger.dart';

import '../../../../core/presentation/theme/responsive_theme.dart';
import '../../../store/domain/entities/store.dart';

class StoreSection extends StatelessWidget {
  final List<StoreBrand> stores;

  const StoreSection({
    Key? key,
    required this.stores,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) {
      return SizedBox.shrink();
    }

    // Calculate responsive dimensions
    final double storeWidth = context.responsiveItemSize(100);
    final double sectionHeight = context.responsiveItemSize(140);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: sectionHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: context.xs),
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return Container(
                width: storeWidth,
                margin: EdgeInsets.symmetric(horizontal: context.xs),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StoreImageButton(
                      store: store,
                    ),
                    SizedBox(height: context.m),
                    Text(
                      store.name,
                      style: context.bodyMedium,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class StoreImageButton extends StatelessWidget {
  final StoreBrand store;

  const StoreImageButton({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = context.responsiveItemSize(100);
    final AppLogger logger = AppLogger();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: context.secondaryColor,
            blurRadius: 2,
            spreadRadius: 0.5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(context.xs),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [context.primaryColor, context.secondaryColor],
            ),
            boxShadow: [
              BoxShadow(
                color: context.secondaryColor,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(context.xs),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: context.secondaryColor,
                    blurRadius: 2,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: store.imageLogo.isNotEmpty
                  ? Image.network(
                      store.imageLogo,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: context.surfaceColor,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        logger.error('Error loading store image: $error');
                        return Container(
                          color: context.surfaceColor,
                          child: Icon(
                            Icons.store,
                            size: size * 0.4,
                            color: context.textSecondaryColor,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: context.surfaceColor,
                      child: Icon(
                        Icons.store,
                        size: size * 0.4,
                        color: context.textSecondaryColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
