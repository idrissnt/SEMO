import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({
    String? storeId,
    String? categoryId,
    String? parentCategoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    bool? isAvailable,
    bool? isSeasonal,
  });
  
  Future<Product> getProductById(String id);
  
  Future<List<Product>> getProductAvailability(String productId);
  
  Future<List<Product>> getSeasonalProducts();
}
