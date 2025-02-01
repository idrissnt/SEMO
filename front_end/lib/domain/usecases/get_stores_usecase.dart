import '../../data/models/store_model.dart';
import '../entities/store.dart';
import '../repositories/store_repository.dart';
import '../../core/utils/logger.dart';

class GetStoresUseCase {
  final StoreRepository storeRepository;
  // ignore: unused_field
  final AppLogger _logger = AppLogger();

  GetStoresUseCase({required this.storeRepository});

  Future<Map<String, List<StoreModel>>> getStoresData() async {
    Map<String, List<Store>> storesMap =
        await storeRepository.getStores(isBigStore: true, name: 'carrefour');

    // Convert the stores map to StoreModel map
    final Map<String, List<StoreModel>> storeModelMap = {
      'bigStores':
          (storesMap['bigStores'] ?? []).map(StoreModel.fromEntity).toList(),
      'smallStores':
          (storesMap['smallStores'] ?? []).map(StoreModel.fromEntity).toList(),
      'storesByName':
          (storesMap['storesByName'] ?? []).map(StoreModel.fromEntity).toList(),
    };

    _logger.debug('GetStoresUseCase: Retrieved stores for home screen - '
        'big: ${storeModelMap['bigStores']?.length}, '
        'small: ${storeModelMap['smallStores']?.length}, '
        'byName: ${storeModelMap['storesByName']?.length}');

    return storeModelMap;
  }
}
