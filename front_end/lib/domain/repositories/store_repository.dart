import '../entities/store.dart';
import '../entities/product.dart';
import '../entities/category.dart';

abstract class StoreRepository {
  Future<List<Store>> getStores({
    String? search,
    bool? isOpen,
    double? minRating,
    bool? isBigStore,
  });

  Future<Store> getStoreById(String id);

  Future<List<Product>> getStoreProducts(String storeId);

  Future<List<Category>> getStoreCategories(String storeId);

  Future<Store> rateStore(String storeId, double rating);
}
