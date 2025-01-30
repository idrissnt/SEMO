// ignore_for_file: avoid_print

import '../repositories/product_repository.dart';
import '../entities/product.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<Product>> getAllProducts() async {
    print('GetProductsUseCase: Getting all products');
    try {
      final products = await repository.getProducts();
      print('GetProductsUseCase: Got ${products.length} products');
      return products;
    } catch (e) {
      print('GetProductsUseCase: Error getting products - $e');
      rethrow;
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    print('GetProductsUseCase: Getting products for category $category');
    try {
      final products = await repository.getProducts(categoryId: category);
      print(
          'GetProductsUseCase: Got ${products.length} products for category $category');
      return products;
    } catch (e) {
      print('GetProductsUseCase: Error getting products by category - $e');
      rethrow;
    }
  }
}
