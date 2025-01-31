import '../../data/models/store_model.dart';
import '../entities/store.dart';
import '../repositories/store_repository.dart';
import '../../core/utils/logger.dart';

class GetStoresUseCase {
  final StoreRepository storeRepository;
  final AppLogger _logger = AppLogger();

  GetStoresUseCase({required this.storeRepository});

  Future<List<StoreModel>> getBigStores() async {
    List<Store> stores = await storeRepository.getStores(isBigStore: true);
    return stores.map(StoreModel.fromEntity).toList();
  }

  Future<List<StoreModel>> getSmallStores() async {
    List<Store> stores = await storeRepository.getStores(isBigStore: false);
    return stores.map(StoreModel.fromEntity).toList();
  }

  Future<List<StoreModel>> getAllStores() async {
    try {
      List<Store> stores = await storeRepository.getStores();

      // Enhanced logging
      _logger.debug(
          'GetStoresUseCase: Total stores from repository: ${stores.length}');

      // for (var store in stores) {
      //   _logger.debug('Store in getAllStores:', error: {
      //     'Name': store.name,
      //     'Is Big Store': store.isBigStore,
      //     'Logo URL': store.logoUrl,
      //   });
      // }

      return stores.map((store) => StoreModel.fromEntity(store)).toList();
    } catch (e) {
      _logger.error('GetStoresUseCase: Error getting all stores: $e');
      rethrow;
    }
  }
}
