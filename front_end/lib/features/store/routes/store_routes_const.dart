/// Constants for store-related routes
class StoreRoutesConst {
  /// for Hero transition
  static String getStoreHeroTag(String storeId) => 'store-$storeId';

  /// Base and selected store route
  static const String storeBase = '/store';
  static const String selectedStore = '/store/:storeId';

  /// Tab routes
  static const String storeShop = 'shop';
  static const String storeAisles = 'aisles';
  static const String storeBuyAgain = 'buyagain';

  /// selected store aisle routes
  static const String storeProductForAisle = ':aisleId';

  // Name constants (new)
  static const String storeDetailName = 'storeDetail';
  static const String storeAislesName = 'storeAisles';
  static const String storeBuyAgainName = 'storeBuyAgain';
  static const String storeProductForAisleName = 'storeProductForAisle';

  //// Helper methods ////
  /// Helper method for selected store route
  static String getStoreDetailRoute(String storeId) => '/store/$storeId';

  /// Helper methods for tab routes
  static String getStoreShopRoute(String storeId) =>
      '/store/$storeId/$storeShop';
  static String getStoreAislesRoute(String storeId) =>
      '/store/$storeId/$storeAisles';
  static String getStoreBuyAgainRoute(String storeId) =>
      '/store/$storeId/$storeBuyAgain';

  /// Helper method for aisle routes
  static String getStoreProductForAisleRoute(String storeId, String aisleId) =>
      '/store/$storeId/$storeAisles/$aisleId';
}
