// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/store.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: isLarge ? 140 : 140, // before: 160 : 140
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return Container(
                width: isLarge ? 100 : 95,
                margin: EdgeInsets.symmetric(horizontal: 4),
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
                    SizedBox(height: 12),
                    Text(
                      store.name,
                      style: TextStyle(
                        fontSize: isLarge ? 14 : 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
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
        const SizedBox(height: 16),
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
    final size = widget.isLarge ? 100.0 : 80.0;

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
            colors: const [Colors.blueAccent, Colors.black],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(3.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  spreadRadius: 0.5,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                splashColor: Colors.black.withOpacity(0.3),
                highlightColor: Colors.black.withOpacity(0.1),
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
                            color: Colors.grey[100],
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
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.store,
                              size: size * 0.4,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.store,
                          size: size * 0.4,
                          color: Colors.grey[400],
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
