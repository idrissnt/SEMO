// ignore_for_file: avoid_print, unnecessary_cast

import '../entities/store.dart';
import '../entities/product.dart';
import '../repositories/store_repository.dart';
import '../repositories/product_repository.dart';

class GetHomeDataUseCase {
  final StoreRepository storeRepository;
  final ProductRepository productRepository;

  GetHomeDataUseCase({
    required this.storeRepository,
    required this.productRepository,
  });

  Future<HomeData> execute() async {
    try {
      // Fetch all stores
      final allStores = await storeRepository.getStores().catchError((e) {
        print('Error fetching all stores: $e');
        return <Store>[];
      });

      // Find the store with the highest rating
      final highestRatedStore = _findHighestRatedStore(allStores);

      // Get products for the highest-rated store
      final storeProducts = highestRatedStore != null
          ? await storeRepository.getStoreProducts(highestRatedStore.id)
          : <Product>[];

      // Filter big and small stores
      final bigStores = _findBigStores(allStores);
      final smallStores = _findSmallStores(allStores);

      return HomeData(
        bigStores: bigStores,
        smallStores: smallStores,
        storeProducts: _findLowestPriceProducts(storeProducts),
        allStores: allStores,
      );
    } catch (e) {
      print('Error in GetHomeDataUseCase: $e');
      // Return empty lists if there's an error
      return HomeData(
        bigStores: [],
        smallStores: [],
        storeProducts: [],
        allStores: [],
      );
    }
  }

  Store? _findHighestRatedStore(List<Store> stores) {
    if (stores.isEmpty) return null;

    // Sort stores by rating in descending order
    final sortedStores = List<Store>.from(stores)
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));

    // Return the first store (highest rated)
    return sortedStores.first;
  }

  List<Store> _findBigStores(List<Store> stores) {
    // Filter stores that are marked as big stores or have many products
    return stores
        .where((store) =>
            (store.isBigStore == true) ||
            (store.totalProducts != null && store.totalProducts! > 10))
        .toList();
  }

  List<Store> _findSmallStores(List<Store> stores) {
    // Filter stores that are not big stores
    return stores
        .where((store) =>
            (store.isBigStore == false) ||
            (store.totalProducts != null && store.totalProducts! <= 10))
        .toList();
  }

  List<Product> _findLowestPriceProducts(List<Product> products) {
    if (products.isEmpty) return [];

    // Sort products by lowest price in the price range
    final sortedProducts = List<Product>.from(products)
      ..sort((a, b) => (a.priceRange.isNotEmpty
              ? a.priceRange.first
              : double.infinity)
          .compareTo(
              b.priceRange.isNotEmpty ? b.priceRange.first : double.infinity));

    // Return the first few products with the lowest price
    return sortedProducts.take(5).toList();
  }
}

class HomeData {
  final List<Store> bigStores;
  final List<Store> smallStores;
  final List<Product> storeProducts;
  final List<Store> allStores;

  HomeData({
    required this.bigStores,
    required this.smallStores,
    required this.storeProducts,
    required this.allStores,
  });
}
