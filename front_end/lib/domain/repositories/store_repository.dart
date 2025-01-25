import '../entities/store.dart';

abstract class StoreRepository {
  Future<List<Store>> getNearbyStores();
  Future<List<Store>> getPopularStores();
  Future<Store> getStoreById(int id);
  Future<List<Store>> searchStores(String query);
}
