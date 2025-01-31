// ignore_for_file: avoid_print

import '../repositories/product_repository.dart';
import '../entities/product.dart';
import '../../core/utils/logger.dart';

class GetProductsUseCase {
  final ProductRepository repository;
  final AppLogger _logger = AppLogger();

  GetProductsUseCase(this.repository);

  Future<List<Product>> getAllProducts() async {
    _logger.info('GetProductsUseCase: Getting all products');
    try {
      final products = await repository.getProducts();
      _logger.debug('GetProductsUseCase: Got ${products.length} products');
      return products;
    } catch (e) {
      _logger.error('GetProductsUseCase: Error getting products', error: e);
      rethrow;
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    _logger.info('GetProductsUseCase: Getting products for category $category');
    try {
      final products = await repository.getProducts(categoryId: category);
      _logger.debug('GetProductsUseCase: Got ${products.length} products for category $category');
      return products;
    } catch (e) {
      _logger.error('GetProductsUseCase: Error getting products by category', error: e);
      rethrow;
    }
  }
}
