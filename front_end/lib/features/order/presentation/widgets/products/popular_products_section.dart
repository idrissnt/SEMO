import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:semo/core/presentation/theme/app_colors.dart';
import 'package:semo/core/utils/logger.dart';
import 'package:semo/features/order/routes/const.dart';
import 'package:semo/features/store/domain/entities/store.dart';
import 'package:semo/features/store/presentation/widgets/products/product_card.dart';

class PopularProductsSection extends StatelessWidget {
  final StoreBrand storeWithProducts;

  final AppLogger _logger = AppLogger();

  PopularProductsSection({
    Key? key,
    required this.storeWithProducts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (storeWithProducts.aisles?.first.categories.first.products.isEmpty ??
        true) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        _buildProductsList(),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 4, top: 8, bottom: 8),
        child: Row(
          children: [
            // Store logo
            _buildStoreLogo(),
            const SizedBox(width: 8),
            // Section title with store name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeWithProducts.aisles?.first.categories.first.name ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    storeWithProducts.aisles?.first.name ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // See all button
            TextButton(
              onPressed: () {
                context.goNamed(OrderRoutesConstants.productByStoreName,
                    pathParameters: {
                      'storeName': storeWithProducts.id,
                      'aisleName': storeWithProducts.aisles?.first.id ?? '',
                      'categoryName':
                          storeWithProducts.aisles?.first.categories.first.id ??
                              '',
                      'productName':
                          'all' // Using 'all' as a placeholder for showing all products
                    },
                    extra: {
                      'store': storeWithProducts,
                    });
              },
              child: const Row(
                children: [
                  Text('Voir tout'),
                  Icon(Icons.arrow_forward_ios, size: 12),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStoreLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        shape: BoxShape.circle,
        image: storeWithProducts.imageLogo.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(storeWithProducts.imageLogo),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  _logger.error('Error loading store logo: $exception');
                },
              )
            : null,
      ),
      child: storeWithProducts.imageLogo.isEmpty
          ? const Icon(Icons.store, size: 16, color: Colors.grey)
          : null,
    );
  }

  Widget _buildProductsList() {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount:
            storeWithProducts.aisles?.first.categories.first.products.length,
        itemBuilder: (context, index) {
          final product =
              storeWithProducts.aisles?.first.categories.first.products[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            child:
                ProductCard(product: product!, storeId: storeWithProducts.id),
          );
        },
      ),
    );
  }
}
