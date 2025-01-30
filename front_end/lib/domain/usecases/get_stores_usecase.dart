import '../../data/models/store_model.dart';
import '../entities/store.dart';
import '../repositories/store_repository.dart';

class GetStoresUseCase {
  final StoreRepository storeRepository;

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
    List<Store> stores = await storeRepository.getStores();
    return stores.map((store) => StoreModel.fromEntity(store)).toList();
  }
}
