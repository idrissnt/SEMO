import '../../entities/stores/store.dart';

abstract class GetStoresUseCase {
  Future<Map<String, List<Store>>> getStoresData({String? name});
  Future<Store?> getStoreDetails(String storeId);
}
