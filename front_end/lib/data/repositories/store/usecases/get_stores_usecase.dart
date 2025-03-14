import '../../../models/store/store_model.dart';
import '../../../../domain/entities/stores/store.dart';
import '../../../../domain/repositories/store/store_repository.dart';
import '../../../../core/utils/logger.dart';

class GetStoresUseCase {
  final StoreRepository storeRepository;
  final AppLogger _logger = AppLogger();

  GetStoresUseCase({required this.storeRepository});

  Future<Map<String, List<StoreModel>>> getStoresData({String? name}) async {
    _logger.debug('GetStoresUseCase: Getting lightweight store list');

    // Call the repository with the lightweight endpoint
    Map<String, List<Store>> storesMap = await storeRepository.getStores(
      isBigStore: true,
      name: name,
    );

    // Convert the stores map to StoreModel map
    final Map<String, List<StoreModel>> storeModelMap = {
      'bigStores':
          (storesMap['bigStores'] ?? []).map(StoreModel.fromEntity).toList(),
      'smallStores':
          (storesMap['smallStores'] ?? []).map(StoreModel.fromEntity).toList(),
      'storesByName':
          (storesMap['storesByName'] ?? []).map(StoreModel.fromEntity).toList(),
    };

    _logger.debug('GetStoresUseCase: Retrieved lightweight stores - '
        'big: ${storeModelMap['bigStores']?.length}, '
        'small: ${storeModelMap['smallStores']?.length}, '
        'byName: ${storeModelMap['storesByName']?.length}');

    return storeModelMap;
  }

  Future<StoreModel?> getStoreDetails(String storeId) async {
    _logger
        .debug('GetStoresUseCase: Getting full details for store ID: $storeId');

    final store = await storeRepository.getStoreById(storeId);

    if (store == null) {
      _logger.warning('GetStoresUseCase: Store not found with ID: $storeId');
      return null;
    }

    final storeModel =
        store is StoreModel ? store : StoreModel.fromEntity(store);
    _logger.debug(
        'GetStoresUseCase: Successfully retrieved store details: ${storeModel.name}');

    return storeModel;
  }
}
