import '../../entities/stores/store.dart';

abstract class StoreRepository {
  // Get lightweight list of all stores
  Future<Map<String, List<Store>>> getStores({
    String? name,
    bool? isBigStore,
  });

  // Get full details for a specific store by ID
  Future<Store?> getStoreById(String storeId);
}
