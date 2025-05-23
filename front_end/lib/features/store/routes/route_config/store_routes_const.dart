/// Constants for store-related routes
class StoreRoutesConst {
  /// for Hero transition - creates a unique tag for each store
  static String getStoreHeroTag(String storeId) => 'store-$storeId';

  // Non-parameterized paths for StatefulShellBranch initial routes
  static const String storeBase = '/store';
  static const String storeAisles = '/aisles';
  static const String storeBuyAgain = '/buyagain';

  static const String storeProductForAisle = 'aisle-detail';
  static const String storeProductList = 'product-list';

  static const String productsQuickView = ':storeName/:aisleName/:categoryName';

  // Name constants
  static const String storeName = 'store';
  static const String storeAislesName = 'storeAisles';
  static const String storeBuyAgainName = 'storeBuyAgain';
  static const String storeProductForAisleName = 'storeProductForAisle';
  static const String storeProductListName = 'storeProductList';
  static const String productsQuickViewName = 'productsQuickView';
}
