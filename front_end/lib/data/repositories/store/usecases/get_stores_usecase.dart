import '../../../../domain/entities/stores/store.dart';
import '../../../../domain/repositories/store/store_repository.dart';
import '../../../../domain/usecases/store/get_stores_usecase.dart';
import '../../../../core/utils/logger.dart';

class GetStoresUseCaseImpl implements GetStoresUseCase {
  final StoreRepository storeRepository;
  final AppLogger _logger = AppLogger();

  GetStoresUseCaseImpl({required this.storeRepository});

  @override
  Future<Map<String, List<Store>>> getStoresData({String? name}) async {
    _logger.debug('GetStoresUseCase: Getting lightweight store list');

    // Call the repository with the lightweight endpoint
    Map<String, List<Store>> storesMap = await storeRepository.getStores(
      isBigStore: true,
      name: name,
    );

    _logger.debug('GetStoresUseCase: Retrieved lightweight stores - '
        'big: ${storesMap["bigStores"]?.length}, '
        'small: ${storesMap["smallStores"]?.length}, '
        'byName: ${storesMap["storesByName"]?.length}');

    return storesMap;
  }

  @override
  Future<Store?> getStoreDetails(String storeId) async {
    _logger
        .debug('GetStoresUseCase: Getting full details for store ID: $storeId');

    final store = await storeRepository.getStoreById(storeId);

    if (store == null) {
      _logger.warning('GetStoresUseCase: Store not found with ID: $storeId');
      return null;
    }

    _logger.debug(
        'GetStoresUseCase: Successfully retrieved store details: ${store.name}');

    return store;
  }
}
