import '../entities/category.dart';
import '../entities/product.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories({
    String? storeId,
    bool? rootOnly,
  });
  
  Future<Category> getCategoryById(String id);
  
  Future<List<Product>> getCategoryProducts(String categoryId);
  
  Future<List<Category>> getCategorySubcategories(String categoryId);
}
