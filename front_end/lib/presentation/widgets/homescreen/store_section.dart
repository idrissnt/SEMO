// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/theme_extension.dart';
import '../../../domain/entities/stores/store.dart';

class StoreSection extends StatelessWidget {
  final String title;
  final List<Store> stores;
  final bool isLarge;

  final AppLogger _logger = AppLogger();

  StoreSection({
    Key? key,
    required this.title,
    required this.stores,
    required this.isLarge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) {
      return SizedBox.shrink();
    }

    // Calculate responsive dimensions
    final double storeWidth = context.responsiveItemSize(isLarge ? 100 : 95);
    final double sectionHeight =
        context.responsiveItemSize(isLarge ? 140 : 130);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: context.l),
          child: Text(
            title,
            style: context.sectionTitle,
          ),
        ),
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
                      isLarge: isLarge,
                      onTap: () {
                        _logger.info('Navigating to store: ${store.name}');
                        context.go('/store/${store.id}');
                      },
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
        SizedBox(height: context.l),
      ],
    );
  }
}

class StoreImageButton extends StatefulWidget {
  final Store store;
  final bool isLarge;
  final VoidCallback onTap;

  const StoreImageButton({
    Key? key,
    required this.store,
    required this.isLarge,
    required this.onTap,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _StoreImageButtonState createState() => _StoreImageButtonState();
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
    // Calculate responsive size based on device width
    final baseSize = widget.isLarge ? 100.0 : 80.0;
    final size = context.responsiveItemSize(baseSize);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: size,
        height: size,
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
              offset: Offset(0, 2),
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
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Material(
              color: context.surfaceColor,
              shape: CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                splashColor: context.secondaryColor,
                highlightColor: context.secondaryColor,
                onTap: () {
                  _controller.forward().then((_) {
                    _controller.reverse().then((_) {
                      widget.onTap();
                    });
                  });
                },
                child: widget.store.logoUrl != null
                    ? Image.network(
                        widget.store.logoUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: context.surfaceColor,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          final logger = AppLogger();
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
                          color: context.surfaceColor,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
