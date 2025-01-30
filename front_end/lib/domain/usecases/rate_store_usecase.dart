import '../entities/store.dart';
import '../repositories/store_repository.dart';

class RateStoreUseCase {
  final StoreRepository repository;

  RateStoreUseCase(this.repository);

  Future<Store> call(String storeId, double rating) async {
    // Validate rating is between 1 and 5
    if (rating < 1.0 || rating > 5.0) {
      throw ArgumentError('Rating must be between 1.0 and 5.0');
    }

    return await repository.rateStore(storeId, rating);
  }
}
