/// Constants for store-related routes
class StoreRoutesConst {
  /// Base route for store
  static const String storeBase = '/store';

  /// Route for store detail with parameter
  static const String storeDetail = '/store/:storeId';

  /// Tab routes
  static const String storeShop = 'shop';
  static const String storeAisles = 'aisles';
  static const String storeBuyAgain = 'buyagain';

  /// Aisle routes
  static const String storeProductForAisle = 'aisle/:aisleId';

  /// Helper method to generate store detail route
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
      '/store/$storeId/aisle/$aisleId';
}
