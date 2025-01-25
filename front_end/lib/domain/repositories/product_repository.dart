import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getSeasonalProducts();
  Future<Product> getProductById(int id);
  Future<List<Product>> searchProducts(String query);
  Future<List<Product>> getProductsByStore(int storeId);
}
