import '../entities/store.dart';

abstract class StoreRepository {
  Future<Map<String, List<Store>>> getStores({
    String? name,
    bool? isBigStore,
  });
}
