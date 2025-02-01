// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import '../../../domain/entities/store.dart';

class StoreSection extends StatelessWidget {
  final String title;
  final List<Store> stores;
  final bool isLarge;

  const StoreSection({
    Key? key,
    required this.title,
    required this.stores,
    required this.isLarge,
  }) : super(key: key);

  Widget _buildCircularStoreImage(Store store, BuildContext context) {
    final size = isLarge ? 100.0 : 80.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: store.logoUrl != null
            ? Image.network(
                store.logoUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[100],
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
                  print('Error loading store image: $error');
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: isLarge ? 160 : 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return Container(
                width: isLarge ? 120 : 100,
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // TODO: Implement store details navigation
                      print('Tapped store: ${store.name}');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCircularStoreImage(store, context),
                        SizedBox(height: 12),
                        Text(
                          store.name,
                          style: TextStyle(
                            fontSize: isLarge ? 14 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
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
